const res = await fetch('http://localhost:1234/v1/chat/completions', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer lm-studio' },
  body: JSON.stringify({
    model: 'google/gemma-3-4b',
    messages: [{ role: 'user', content: 'You are a router. Output ONLY valid JSON: {"match": "general"}' }]
  })
});
const data = await res.json();
console.log('Output:', data.choices[0].message.content);
