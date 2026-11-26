# Dairy Voice Agent with Multilingual Routing

An LLM voice agent for dairy farmers. The farmer calls, asks about his cows in Telugu, Hindi, Hinglish or English, and hears the answer back in the same language.

Built by Nihar Nandala

**[See the page →](https://niharnandala.github.io/dairy-voice-agent-multilingual-routing/)**

---

## status

I am building this now. The working demo goes live on **Monday, 30 November 2026**. Until then this repo has the idea page and this README, and I will push the code as I build it.

## what happens on 1 call

```
farmer calls  →  voice to text  →  router  →  find the answer  →  reply on the call
                 (detect language)            (right source)       (same language)
```

The farmer doesn't open any app. Everything happens inside the call, even asking what his cow might sell for.

| the farmer asks | where the answer comes from |
| --- | --- |
| "which cow gave the least milk today" | his own cow records in Postgres |
| "does Gir handle hot weather" | breed knowledge base, RAG |
| "my cow has a fever, what do I do" | vet knowledge base, RAG, preliminary guidance only |
| "my cow fell down and can't breathe" | emergency, it skips the advice and tells him to call the vet now |
| "how much can I sell my 4 year old Gir for" | past sales of similar cows, averaged over the last 12 months |

## why it is not starting from zero

I already built this flow once for banking, [Banking Voice Agent](https://github.com/niharnandala/Banking_Voice_Agent_With_intelligent_Routing). Same LangGraph router, same Groq LLM, same Postgres on Neon, same ChromaDB RAG, same Vachana TTS for Indian voices. On 95 labelled cases it got 95.8% intent accuracy and 93.7% language accuracy, with a 2.97s median latency.

[demo video](https://drive.google.com/file/d/1S4kGOt0-BQXdQx4PE6W_UFVGNt6d65on/view) · [live app](https://banking-voice-agent-with-intelligent.onrender.com/ui)

The farm version swaps the bank handlers for farm handlers and adds a price handler. The first thing I will fix is the Hindi vs Hinglish confusion I found in the banking evals, because farmers mix in words like "vaccine" and "injection" the same way bank customers mix in "loan" and "EMI".

## the honest parts

- I am building this on free tiers, so I will add or remove features based on the free resources I can actually get.
- The database is limited for now. The cows and sales in it are generated sample data, not real farm records.
- For the first version, herd questions use a fixed set of queries instead of free text to SQL, because they are predictable and much harder to break in a demo.
- The first version runs in the browser with a mic, like the banking one. Real phone calls come after that.
- Health answers never diagnose or prescribe medicine.
- Prices are estimates from past sales, never a promise.
