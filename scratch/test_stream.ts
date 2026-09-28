import { createOpenAI } from "@ai-sdk/openai";
import { streamText } from "ai";

const openai = createOpenAI({
  apiKey: process.env.OPENAI_API_KEY || "lm-studio",
  baseURL: process.env.OPENAI_BASE_URL || "http://localhost:1234/v1",
});

const model = openai("google/gemma-3-4b");

console.log("Model initialized:", model.modelId, model.provider);

try {
  const result = streamText({
    model,
    messages: [
      { role: "system", content: "You are a helpful assistant." },
      { role: "user", content: "Say hello in one word." },
    ],
  });

  for await (const part of result.fullStream) {
    console.log("Part type:", part.type);
    if (part.type === "text-delta") {
      process.stdout.write(part.text);
    } else if (part.type === "error") {
      console.error("Stream error part:", part.error);
    }
  }
  console.log("\nFinished successfully!");
} catch (err) {
  console.error("Caught error:", err);
}
