# Simulation Frontend Handoff

## Scope

This document summarizes the current frontend-only simulation quest flow so the backend can replace mock data with API data without changing the agreed API contract.

No backend schema or endpoint change is requested here.

## Current Screens

- `SimulationQuestListScreen`: unlocked/locked simulation quest list.
- `SimulationProgressScreen`: simulation intro and five-step overview.
- `SimulationDocumentSelectionScreen`: step 1, document selection.
- `SimulationContractReviewScreen`: step 2, contract clause check.
- `SimulationPaymentScreen`: step 3, contract deposit payment method and user-entered payment amount.
- `SimulationLoanScreen`: step 4, group loan comparison.
- `SimulationSettlementScreen`: step 5, final payment/registration and user-entered acquisition-tax calculation.
- `SimulationCompleteScreen`: completion summary and XP/result review.

## Existing API Endpoints To Connect

Use the existing constants in `lib/core/constants/api_endpoints.dart`.

- `ApiEndpoints.simulations`
- `ApiEndpoints.startSimulation(simulationId)`
- `ApiEndpoints.simulationStep(attemptId, stepNo)`
- `ApiEndpoints.submitSimulationAnswer(attemptId, stepNo)`
- `ApiEndpoints.completeSimulation(attemptId)`

## Mock Data Boundaries

The following values are currently visual mock data and should be replaced by backend responses later.

- Quest list: title, subtitle, unlocked/locked state, reward condition.
- Simulation context: apartment type, sale price, winning date, contract deadline.
- Step text: situation title, prompt, choice/card labels, hints, recommended answer labels.
- Completion summary: journey rows, concept bullet list, XP amount.

## User Input Fields

These values are intentionally editable in the frontend now.

- Contract deposit amount in `SimulationPaymentScreen`.
- Expected acquisition tax amount in `SimulationSettlementScreen`.

Sale price and acquisition tax rate are displayed as scenario/reference values, not user-editable values. Backend scoring/validation should still follow the agreed simulation answer APIs.

## Placeholder Actions

- The `복습` buttons on the completion screen only provide tap feedback for now.
- Connect them later only after the review/preview destination is confirmed in the API or planning spec.
