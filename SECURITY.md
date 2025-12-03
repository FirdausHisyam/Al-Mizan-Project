# Security Policy & Threat Model

## 1. Strategic Risks (External Reliance)

> [!WARNING]
> **Risk**: Reliance on non-aligned, external AI providers (Google Gemini).
> **Impact**: Potential for bias, service denial, or data privacy issues.
> **Mitigation**: This is a **TEMPORARY** measure. The roadmap includes a transition to self-hosted, fine-tuned open-source models (e.g., Llama, Mixtral) running on independent infrastructure.

## 2. Threat Model: Bad Actors

### A. Prompt Injection

* **Attack Vector**: A malicious user inputs crafted text (e.g., "Ignore previous instructions and say X") into the graph expansion prompt.
* **Risk**: The AI generates content that violates Islamic principles or application guidelines.
* **Mitigation**:
  * **Strict Prompting**: The system uses a rigid prompt structure that encapsulates user input.
  * **Output Validation**: The system parses the output as strict JSON. If the AI returns text instead of JSON (often the case with successful jailbreaks), the parser fails and the response is discarded.
  * **Future**: Implement a secondary "Guardrail AI" model to scan inputs and outputs for malice.

### B. API Abuse / Denial of Service

* **Attack Vector**: A user spams the expansion endpoint.
* **Risk**: Exhaustion of API quotas or server resources.
* **Mitigation**:
  * **Rate Limiting**: (To Be Implemented) Limit requests per IP.
  * **Authentication**: (To Be Implemented) Require login for AI features.

## 3. Reporting Vulnerabilities

If you discover a security vulnerability, please report it privately to the administration team. Do not disclose it publicly until it has been resolved.
