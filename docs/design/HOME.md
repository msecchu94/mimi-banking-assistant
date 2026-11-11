Mimi — Mobile Banking Home
Status: DS-04 Approved Baseline
Figma: 02 — Home
Design System: docs/design/DESIGN_SYSTEM.md
Flutter implementation: FL-06
Purpose
Home is the primary banking dashboard.
The experience must feel primarily like a mature digital bank. Mimi is an integrated intelligent capability, not the dominant visual element.
Hierarchy
Customer context
Available balance
Primary actions
Account summary
Recent transactions
Mimi entry point
The balance is the strongest financial element.
Content
Header
Hola, Lucía
Tu caja de ahorro en pesos
Profile action
Balance
Saldo disponible · ARS
$ 1.284.650,75
Show/hide balance control
Quick actions
Transferir — primary
Pagar
Tarjetas
Account summary
Current DS-04 content:
Débito · •••• 4821
Activa · Lucía Fernández
Alias de tu cuenta
lucia.fernandez.ars
Ver datos
Recent transactions
Supermercado Día — − $ 32.480,50
Martín López — + $ 85.000,00
Personal — − $ 18.900,00
Ver todos
Mimi
Use the approved ✦ Mimi FAB.
It must remain visible without competing with financial information.
FL-06 Behavior
Balance, account name/status and the account's 3 newest transactions come from the backend's read-only endpoints (API_CONTRACT.md §33), for the customer's ARS account. Greeting, account description, holder name and alias are presentation-only static copy.
While loading, Home shows a progress indicator in place of the account content; on failure, a message with a retry.
When Mimi reports a completed transfer, Home reloads this data from the backend right away, even with Mimi open, keeping the current content until it arrives. A changed balance cross-fades; a new transaction enters at the top while the one no longer among the newest 3 exits (about 300 ms).
Only the balance visibility interaction is required.
Transferir, Pagar, Tarjetas, Ver datos and Ver todos do not require real flows in FL-06.
Do not create temporary destination screens.
Layout
Follow DESIGN_SYSTEM.md.
Use responsive, content-driven Flutter layouts. Avoid translating absolute Figma coordinates.
Target common mobile widths, including approximately 320 px and above.
Out of Scope
Chat / Mimi Bottom Sheet
transfer/payment/card flows
bottom navigation
voice/microphone
speculative architecture or components
DS-05 Pending Refinements
DS-04 remains the FL-06 baseline.
DS-05 will later refine:
header cohesion
subtle balance-area depth
account summary semantics
transaction list treatment
FL-06 must not anticipate these changes.
Source of Truth
DS-02 → Foundations
DS-03 → Components
DS-04 → Home composition
DESIGN_SYSTEM.md → implementation contract
HOME.md → Home-specific requirements
The approved DS-04 Figma screen remains the visual source of truth.