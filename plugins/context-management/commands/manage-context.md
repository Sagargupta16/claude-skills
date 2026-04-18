---
description: Assess current context health and recommend compaction, clearing, or sub-agent strategy
user_invocable: true
---

Analyze the current session's context health:

1. Estimate how much context has been used (based on conversation length and file reads)
2. Check for signs of context rot (repeated mistakes, ignored rules, generic output)
3. Recommend one of:
   - **Continue**: Context is healthy, keep working
   - **Compact**: Context is 40-60% full, compact with specific retention instructions
   - **Clear**: Context is polluted with failed approaches, start fresh
   - **New session**: Context is severely degraded or task is completely different
4. If recommending compact, provide specific `/compact` instructions that retain the important context and drop the noise
