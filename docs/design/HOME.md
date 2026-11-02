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
Data is local/mock.
Only the balance visibility interaction is required.
Transferir, Pagar, Tarjetas, Ver datos and Ver todos do not require real flows in FL-06.
Do not create temporary destination screens.
Layout
Follow DESIGN_SYSTEM.md.
Use responsive, content-driven Flutter layouts. Avoid translating absolute Figma coordinates.
Target common mobile widths, including approximately 320 px and above.
Out of Scope
backend integration
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