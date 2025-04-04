/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import * as functions from "firebase-functions/v2";
import { defineString } from "firebase-functions/params";
import { HfInference } from "@huggingface/inference";
import * as admin from "firebase-admin";

// Initialize Firebase Admin
admin.initializeApp();

// Define config parameters
const huggingfaceApiKey = defineString("huggingface.apikey");

// Configure the Hugging Face Inference client
const hf = new HfInference(
  process.env.HUGGINGFACE_API_KEY ||
  huggingfaceApiKey.value()
);

export const generateImage = functions.https.onCall(
  {
    memory: "8GiB",
    timeoutSeconds: 540,
    cors: true,
  },
  async (request) => {
    // Authenticate the request
    if (!request.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
      );
    }

    try {
      const { prompt, negativePrompt } = request.data;

      // Validate inputs
      if (!prompt) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "The function must be called with a \"prompt\" argument.",
        );
      }

      // Call Stable Diffusion 3.5 Large model with recommended parameters
      const response = await hf.textToImage({
        model: "stabilityai/stable-diffusion-3.5-large",
        inputs: prompt,
        parameters: {
          negative_prompt: negativePrompt || "",
          num_inference_steps: 28,
          guidance_scale: 3.5,
          max_sequence_length: 512,
        },
      });

      // Convert image to base64
      const base64Image = Buffer.from(
        await response.arrayBuffer(),
      ).toString("base64");

      return {
        success: true,
        imageData: `data:image/jpeg;base64,${base64Image}`,
      };
    } catch (error) {
      console.error("Error generating image:", error);
      throw new functions.https.HttpsError(
        "internal",
        "An error occurred while generating the image.",
        error instanceof Error ? error.message : "Unknown error",
      );
    }
  },
);

// HTTP endpoint version
export const generateImageHttp = functions.https.onRequest(
  {
    memory: "8GiB",
    timeoutSeconds: 540,
    cors: true,
  },
  async (req, res) => {
    try {
      const { prompt, negativePrompt } = req.body;

      if (!prompt) {
        res.status(400).send({ error: "Prompt is required" });
        return;
      }

      const response = await hf.textToImage({
        model: "stabilityai/stable-diffusion-3.5-large",
        inputs: prompt,
        parameters: {
          negative_prompt: negativePrompt || "",
          num_inference_steps: 28,
          guidance_scale: 3.5,
          max_sequence_length: 512,
        },
      });

      const base64Image = Buffer.from(
        await response.arrayBuffer(),
      ).toString("base64");

      res.status(200).send({
        success: true,
        imageData: `data:image/jpeg;base64,${base64Image}`,
      });
    } catch (error) {
      console.error("Error:", error);
      res.status(500).send({
        error: "Failed to generate image",
        details: error instanceof Error ? error.message : "Unknown error",
      });
    }
  },
);
