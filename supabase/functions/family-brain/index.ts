import { createClient } from 'npm:@supabase/supabase-js@2.49.1'
import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'

const jsonHeaders = { 'Content-Type': 'application/json; charset=utf-8' }

function response(body: Record<string, unknown>, status = 200, extraHeaders: HeadersInit = {}) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...jsonHeaders, ...extraHeaders },
  })
}

serve(async (req) => {
  const requestId = crypto.randomUUID()
  const allowedOrigin = Deno.env.get('ALLOWED_ORIGIN') ?? '*'
  const corsHeaders = {
    'Access-Control-Allow-Origin': allowedOrigin,
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Vary': 'Origin',
  }

  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })
  if (req.method !== 'POST') return response({ error: 'method_not_allowed', requestId }, 405, corsHeaders)

  try {
    const authorization = req.headers.get('Authorization')
    if (!authorization?.startsWith('Bearer ')) {
      return response({ error: 'authentication_required', requestId }, 401, corsHeaders)
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')
    const openAiKey = Deno.env.get('OPENAI_API_KEY')
    if (!supabaseUrl || !anonKey || !openAiKey) {
      return response({ error: 'service_not_configured', requestId }, 503, corsHeaders)
    }

    const token = authorization.slice('Bearer '.length)
    const supabase = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authorization } },
      auth: { persistSession: false, autoRefreshToken: false },
    })

    const { data: userData, error: userError } = await supabase.auth.getUser(token)
    if (userError || !userData.user) {
      return response({ error: 'invalid_session', requestId }, 401, corsHeaders)
    }

    const payload = await req.json().catch(() => null) as { prompt?: unknown; familyId?: unknown } | null
    const prompt = typeof payload?.prompt === 'string' ? payload.prompt.trim() : ''
    const familyId = typeof payload?.familyId === 'string' ? payload.familyId : ''

    if (!prompt || prompt.length > 2000 || !/^[0-9a-f-]{36}$/i.test(familyId)) {
      return response({ error: 'invalid_request', requestId }, 400, corsHeaders)
    }

    const { data: membership, error: membershipError } = await supabase
      .from('family_members')
      .select('role')
      .eq('family_id', familyId)
      .eq('user_id', userData.user.id)
      .maybeSingle()

    if (membershipError || !membership) {
      return response({ error: 'family_access_denied', requestId }, 403, corsHeaders)
    }

    const aiResponse = await fetch('https://api.openai.com/v1/responses', {
      method: 'POST',
      signal: AbortSignal.timeout(30000),
      headers: { Authorization: `Bearer ${openAiKey}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        model: Deno.env.get('OPENAI_MODEL') ?? 'gpt-5-mini',
        max_output_tokens: 700,
        input: [
          {
            role: 'system',
            content: 'You are Family Brain. Provide practical, non-diagnostic and explainable family guidance. Do not infer sensitive traits. Do not reveal identifiers, secrets, or data from another family. State uncertainty and identify which approved context categories influenced the answer.',
          },
          { role: 'user', content: prompt },
        ],
      }),
    })

    const data = await aiResponse.json()
    if (!aiResponse.ok) {
      console.error('OpenAI request failed', { requestId, status: aiResponse.status })
      return response({ error: 'ai_provider_error', requestId }, 502, corsHeaders)
    }

    const answer = typeof data.output_text === 'string' ? data.output_text : ''
    if (!answer) return response({ error: 'empty_ai_response', requestId }, 502, corsHeaders)

    return response({ answer, requestId }, 200, corsHeaders)
  } catch (error) {
    console.error('family-brain failure', { requestId, error: String(error) })
    return response({ error: 'internal_error', requestId }, 500, corsHeaders)
  }
})
