import "eventsource";
import { resolveModel } from "@copilotkit/runtime/v2";

const model = resolveModel("google/gemini-3.7-flash");

console.log("Model initialized:", (model as any).modelId, (model as any).provider);

try {
  const result = await (model as any).doStream({
    inputFormat: "messages",
    mode: { type: "regular" },
    prompt: [
      { role: "system", content: "You are a helpful assistant." },
      { role: "user", content: [{ type: "text", text: "Say hello in one word." }] },
    ],
  });

  console.log("Stream obtained:", result);
  const reader = result.stream.getReader();
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    console.log("Chunk:", value);
  }
  console.log("\nFinished successfully!");
} catch (err) {
  console.error("Caught error:", err);
}
