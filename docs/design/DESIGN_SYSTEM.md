Mimi Design System
Status: Approved baseline
Source: Figma DS-02 Foundations + DS-03 Components
Theme: Dark
Purpose: Shared visual language and implementation contract between Figma and Flutter.

1. Design Principles
Mimi uses one shared visual language for banking and its intelligent layer.
Banking
The banking experience is solid, dark and robust.
It prioritizes:
stability
structure
reliability
financial clarity
strong readability
calm hierarchy
Solid surfaces are the default.
Mimi
Mimi adds intelligence through:
glass
controlled light
restrained ambient color
subtle glow
contextual motion
Mimi is an intelligent layer inside the same banking product, not a separate visual identity.
Core principle
Solid by default. Light only where Mimi adds meaning.
Financial readability always takes priority over atmosphere.

2. Color System
All approved color swatches are bound to local Figma color variables.
Applications should consume these colors semantically instead of introducing arbitrary local values.
2.1 Core / structure / identity / text
Token
Value
Purpose
background
#071A1F
Main application background
surface
#0C252A
Standard cards and surfaces
surfaceElevated
#123238
Elevated or emphasized surfaces
surfaceGlass
#16383D · 70%
Mimi overlays and ambient glass
surfaceGlassStrong
#16383D · 85%
Financial data over the nebula
primary
#19C6B3
Primary actions and Mimi identity
primaryBright
#25E3D2
Highlights and controlled glow
primarySoft
#8EF1E7
Soft teal accents
textPrimary
#F4F8F8
Primary text
textSecondary
#A6BBBC
Secondary text
textMuted
#7D9A9C
Tertiary and supporting text only

2.2 Semantic / financial states
Token
Value
Purpose
success
#35D07F
Successful operations / positive states
warning
#F3B84B
Warning states
error
#F05B68
Errors and destructive actions

Semantic state must never be communicated through color alone.
Pair semantic color with wording, iconography or another explicit state indicator.
2.3 Mimi ambient colors
Token
Value
Purpose
mimiCyan
#22D3C5
Dominant nebula / AI ambience
mimiPurple
#7B67EE
Secondary nebula color
mimiPink
#D65B9E
Limited ambient accent

These are ambient colors, not action or financial-state colors.
Never replace success, warning or error with Mimi ambient colors.
Readability before atmosphere
Never replace financial states with decorative Mimi colors.
Keep critical financial values high contrast.
textMuted must not be used for critical financial information.
Pure black is not the main background.

3. Typography
Font family: Inter
Inter is used throughout both the banking and intelligent layers.
Mimi does not introduce a separate typeface.
DS-02 defines 10 approved text styles.
Token
Size / Weight
Primary use
displayLarge
32 px / 700
Main balances and key financial figures
headlineLarge
28 px / 700
Primary screen titles
headlineMedium
24 px / 600
Important section headings
titleLarge
20 px / 600
Card and Mimi result titles
titleMedium
17 px / 600
Subsections
bodyLarge
16 px / 400
Mimi conversation and prominent body
bodyMedium
14 px / 400
General content
labelLarge
14 px / 600
Actions and important labels
labelMedium
12 px / 500
Categories and supporting labels
caption
11 px / 400
Auxiliary information

3.1 Weight discipline
Use:
700 for key financial figures and truly important information
600 for headings and actions
400 for body content
Avoid excessive bold usage.
Mimi conversation generally uses bodyLarge.
3.2 Financial numerals and line height
Enable tabular figures for financial values where supported.
Figma line height remains AUTO.
The approved Figma text styles are the visual source of truth. Flutter must not invent independent per-screen typography metrics when translating these styles.

4. Spacing
The Design System follows a 4 px base grid.
Token
Value
spaceXs
4 px
spaceSm
8 px
spaceMd
12 px
spaceLg
16 px
spaceXl
20 px
space2xl
24 px
space3xl
32 px
space4xl
40 px
space5xl
48 px

Use the defined scale instead of arbitrary spacing.
Common content gaps are:
8 / 12 / 16 / 24 / 32 px
4.1 Screen inset
Default horizontal screen inset:
20 px (spaceXl)
4.2 Interactive targets
Minimum height for important interactive targets:
48 px
This requirement applies to Flutter interaction areas even when the visible element is visually smaller.

5. Radius
DS-02 defines six approved corner values.
Token
Value
Intended use
radiusXs
6 px
Small indicators and tags
radiusSm
10 px
Chips and compact elements
radiusMd
14 px
Buttons and standard inputs
radiusLg
20 px
Standard banking cards
radiusXl
28 px
Mimi sheets / exposed panel corners
radiusFull
999 px
Pills, avatars and Mimi FAB

Banking cards use radiusLg.
Buttons and inputs use radiusMd.
Mimi may feel more organic while remaining inside the same radius system.

6. Surfaces
Banking is primarily solid.
Strong readability and calm hierarchy take priority over transparency.
Depth comes from:
surface contrast
subtle borders
blur where explicitly required
selective light
Avoid large black shadows.
6.1 Background
background
#071A1F
Base application canvas / petrol depth.
6.2 Surface
surface
#0C252A
Standard banking cards and surfaces.
6.3 Surface Elevated
surfaceElevated
#123238
Elevated or emphasized content.
Surface rule
Banking uses solid structure and reliability.
Mimi adds an intelligent layer to the same product.
Increase opacity whenever financial readability requires protection.

7. Glass Treatments
Glass is selective.
It is not the default treatment for banking content.
7.1 Ambient Glass
Token:
surfaceGlass
Value:
#16383D at 70%
Purpose:
Ambient overlays and Mimi supporting surfaces.
Current Figma construction also uses provisional blur and border properties documented in Section 14.
7.2 Financial Isolation Glass
Token:
surfaceGlassStrong
Value:
#16383D at 85%
Purpose:
Protect important financial information when displayed over the Mimi nebula.
Examples include:
balances
charts
confirmations
transfer information
Glass rule
Use stronger glass when financial content requires isolation from atmospheric backgrounds.
Glass must never reduce readability.

8. Glow
Glow provides controlled emphasis.
It is not a general decoration or neon effect.
The primary glow derives from:
primary / #19C6B3
Reserve glow for:
selected AI indicators
focused elements
selected active states
Mimi-specific emphasis
Mimi FAB where defined by the component design
Do not surround every surface with glow.
The exact glow construction currently used by Figma is provisional and documented separately in Section 14.

9. Mimi Dynamic Nebula
The Mimi Dynamic Nebula is an ambient intelligence layer.
It uses approximately three large, heavily blurred color masses:
dominant cyan
secondary violet
limited pink accent
The result should feel subtly alive and never distracting.
9.1 Motion specification
Target cycle:
15–25 seconds
Use:
slow position shifts
gentle scale changes
subtle opacity variation
Avoid:
abrupt transitions
aggressive pulsation
particles
high-contrast aggressive gradients
The atmosphere should evolve continuously without visibly demanding attention.
9.2 Financial content isolation
Use stronger glass when balances, charts, confirmations, transfer details or other important financial information appear over the nebula.
Motion must never compete with financial information.
9.3 Implementation status
The nebula shown in DS-02 is a static specimen and motion specification.
Its current blur and color-mass opacity construction is provisional and documented in Section 14.
It is not required on screens that do not use the nebula.

10. Component System
DS-03 defines the approved base component library.
It reuses:
32 existing Mimi variables
10 existing Inter text styles
existing approved effects where applicable
DS-03 contains:
8 component sets / 34 variants + 2 standalone masters = 36 components
The documented component families are:
Button
Icon Button
Text Input
Chip
Card
List Item
Semantic Badge
Divider
Mimi Composer
Mimi FAB
Components must reuse Foundations rather than redefine local colors, typography, spacing or radius values.

11. Component Specifications
11.1 Buttons
Buttons are explicit actions.
Approved Figma component variants and states remain the source of truth for exact visual composition.
Implementation principles:
labels remain editable
icon support remains optional where defined
semantic meaning must not rely on color alone
important interactive targets preserve the 48 px minimum
component geometry uses approved Foundation tokens wherever available
Do not create screen-specific button styles when an approved variant already represents the interaction.

11.2 Icon Button
Icon Buttons represent compact icon actions.
Visible geometry may be compact, but Flutter must preserve an appropriate interactive target.
Placeholder Figma glyphs do not define the final application icon library.
Use semantically equivalent production icons while preserving the intended visual weight and alignment.

11.3 Text Input
Text Input is a single labeled field with explicit focus outline and readable error messaging.
Documented states include:
Default
Focused
Filled
Error
Disabled
The structure supports:
field label
editable value
optional leading/trailing icon
helper/supporting content
error content
Error communication must not rely on border color alone.
Visual states must remain clearly distinguishable.

11.4 Chip
Chips represent compact contextual selection and categorization.
Documented states:
Default
Selected
Disabled
Selected state uses a stronger surface and clear outline rather than arbitrary ambient color.
Compact visual sizing must not result in an inaccessible Flutter interaction target.
Do not use Mimi ambient colors as generic chip states.

11.5 Card
Cards provide structure, not decoration.
Documented variants:
Base
Elevated
Glass
Base
Default structural banking container.
Elevated
Provides stronger hierarchy through elevated/emphasized surface treatment.
Glass
Reserved for Mimi contextual content or compositions explicitly requiring the glass recipe.
Card behavior
Card height follows its content.
Avoid arbitrary fixed card heights.
Use approved radius and spacing tokens.
Protect readability before adding transparency.
No shadow is required on standard solid cards unless explicitly defined by the approved composition.

11.6 List Item
List Item is a flexible, feature-agnostic row.
Supported anatomy includes:
optional leading container/icon
primary text
optional supporting description
optional detail/trailing text
optional trailing icon
Primary text anchors the row.
Secondary and trailing content should remain subordinate.
Use optional visibility/composition instead of creating unnecessary combinatorial variants.
If the row is actionable, Flutter must preserve an accessible interaction target.

11.7 Semantic Badge
Semantic badges communicate status.
Documented categories:
Success
Warning
Error
Neutral
Badges are status labels, not controls.
Meaning must be explicit in the label and supported by semantic color.
Never substitute Mimi ambient colors for semantic state colors.

11.8 Divider
Divider creates a quiet boundary between related regions on a dark surface.
Spacing remains the primary grouping mechanism.
Use dividers sparingly.
The current divider construction uses a provisional value documented in Section 14 rather than a dedicated approved Foundation token.

12. Mimi Components
Mimi belongs to the same product and Design System.
Its material treatment is softer and more atmospheric, but it does not introduce a second component language.
The recognizable Mimi symbol is:
✦
No voice, microphone or assistant avatar is part of the approved V1 component specification.

12.1 Mimi Composer
Purpose:
Conversational text entry and send action.
Uses the shared Design System with Mimi-specific material treatment.
Documented behavior includes:
empty / send unavailable
content present / send available
editable text
content-driven text area growth
The component uses radiusFull.
The send interaction must preserve an appropriate touch target.
No microphone or voice control is included in V1.

12.2 Mimi FAB
Approved visible identity:
✦ Mimi
Purpose:
Entry point from the banking experience into Mimi.
Documented states:
Default
Pressed
Rules:
compact pill treatment
visible Mimi name remains present
restrained Mimi-specific light/glow
no mascot
no voice control
do not replace the component with an unlabeled generic AI icon
The FAB should remain discoverable without competing with primary financial information.

13. Construction and Flutter Handoff
13.1 Binding contract
DS-03 reuses the existing approved Mimi variables and Inter text styles by identity.
Color, spacing and radius remain bound to Foundations.
Existing approved effects are linked where applicable rather than recreated.
No new Foundation assets are introduced by DS-03.
13.2 Flutter implementation
Flutter should translate the Design System semantically.
Prefer:
Row
Column
flexible layout
content-driven heights
reusable semantic tokens
existing component equivalents
composition over screen-specific variants
Avoid:
unnecessary fixed heights
arbitrary local colors
arbitrary spacing
absolute-position-heavy layouts
duplicated visual constants
speculative components for future screens
Important controls must preserve a minimum interactive target even if their visual geometry is smaller.
13.3 Editable component anatomy
Labels, values, helper text and other text slots should remain editable.
Optional icon and text layers should be represented through visibility/composition rather than a final icon library dependency or excessive combinatorial variants.
Neutral placeholder glyphs in Figma represent geometry and semantic position, not final production iconography.

14. Provisional Construction Register
The following values describe current Figma construction where a dedicated approved Foundation token does not yet exist.
They are not approved Design System tokens.
They must not be promoted automatically into global Flutter tokens.
14.1 Outlines and divider
Current construction includes:
1 px outlines/divider
2 px focus ring
These are provisional construction values.
14.2 Destructive pressed state
Current destructive pressed treatment uses approximately:
80% opacity
This is provisional.
14.3 Glass
Current Figma glass construction uses provisional effect properties including:
approximately 24 px background blur
subtle border derived from textPrimary
approximately 6% border opacity where documented
These values describe the current glass recipe but are not independent approved Foundation tokens.
14.4 Glow
Current Figma glow construction is approximately:
source: primary
opacity: 24%
offset X: 0
offset Y: 0
blur: 24 px
spread: 0
This remains a provisional effect recipe.
It is not an additional color or glow token.
14.5 Mimi Dynamic Nebula
The static specimen currently uses approximately:
72 px blur
cyan opacity around 24%
violet opacity around 18%
pink opacity around 12%
These values describe the current rendering specimen.
They are not approved motion or Foundation tokens.
14.6 Icon geometry
Current placeholder icon construction references existing spacing values, including approximately:
spaceLg / 16 px
spaceMd / 12 px
Final icon sizing and icon library selection remain implementation decisions.
Do not create global icon-size tokens from these provisional references without explicit approval.
14.7 Compact chip interaction
Compact chip visual sizing may be smaller than the required interactive area.
Flutter must preserve accessible interaction geometry without treating the visual chip height as the touch-target specification.

15. Provisional Value Rule
Provisional values document current Figma construction. They are not approved Design System tokens.
If an approved Flutter screen requires one of these values:
use the narrowest implementation necessary;
keep it scoped to the component/effect that requires it;
document the dependency;
do not silently promote it into the global Design System.
Promotion requires an explicit Design System decision.

16. Accessibility and Financial Clarity
Financial information always takes precedence over atmospheric effects.
Implementation must:
maintain strong foreground/background contrast
avoid communicating financial state through color alone
preserve accessible interaction targets
keep critical financial values on highly readable surfaces
increase isolation/opacity where atmospheric backgrounds could reduce readability
avoid decorative effects that interfere with numeric scanning
Critical financial information must never use textMuted.

17. Design System Governance
Approved sources
DS-02 — Foundations
Defines approved:
colors
typography
spacing
radius
shared surface/effect direction
Mimi ambient behavior
DS-03 — Components
Defines approved base component construction and component behavior.
Foundations remain read-only when building screen compositions.
Screen specifications
Individual screen tickets may compose DS-02 and DS-03 without redefining them.
Example:
DS-04 — Mobile Banking Home V1
defines a screen composition that consumes the approved Design System.
A screen-specific requirement does not automatically become a global Design System rule.
Changes
A screen that exposes a genuine Design System limitation must trigger an explicit review before:
adding a global token
changing an approved token
modifying a global component contract
promoting a provisional construction value
introducing a new global effect
This prevents implementation decisions from becoming accidental Design System rules and keeps Figma and Flutter aligned.

18. Source of Truth and Precedence
For visual implementation:
Approved Figma Foundations define visual tokens.
Approved Figma Components define component appearance and behavior.
Approved screen designs define composition.
This document provides the implementation contract and handoff reference.
Provisional construction values remain provisional unless explicitly promoted.
If this document and an approved Figma asset conflict, the discrepancy must be reviewed rather than silently resolved in Flutter.
Figma remains the visual source of truth.
