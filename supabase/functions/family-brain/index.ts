import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'

serve(async (req) => {
  try {
    const { prompt, familyId } = await req.json()
    if (!prompt || !familyId) return new Response(JSON.stringify({ error: 'prompt and familyId are required' }), { status: 400 })

    const openAiKey = Deno.env.get('OPENAI_API_KEY')
    if (!openAiKey) return new Response(JSON.stringify({ error: 'OPENAI_API_KEY is not configured' }), { status: 503 })

    const response = await fetch('https://api.openai.com/v1/responses', {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${openAiKey}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        model: Deno.env.get('OPENAI_MODEL') ?? 'gpt-5-mini',
        input: [
          { role: 'system', content: 'You are Family Brain. Give practical, explainable family recommendations. Never reveal private family data outside the current family context.' },
          { role: 'user', content: `Family ID: ${familyId}\nRequest: ${prompt}` }
        ]
      })
    })

    const data = await response.json()
    if (!response.ok) return new Response(JSON.stringify({ error: data }), { status: response.status })
    return new Response(JSON.stringify({ answer: data.output_text ?? 'No answer generated.' }), { headers: { 'Content-Type': 'application/json' } })
  } catch (error) {
    return new Response(JSON.stringify({ error: String(error) }), { status: 500 })
  }
})
