---
name: Cognitive Horizon
colors:
  surface: '#131315'
  surface-dim: '#131315'
  surface-bright: '#39393b'
  surface-container-lowest: '#0e0e10'
  surface-container-low: '#1c1b1d'
  surface-container: '#201f22'
  surface-container-high: '#2a2a2c'
  surface-container-highest: '#353437'
  on-surface: '#e5e1e4'
  on-surface-variant: '#b9cacb'
  inverse-surface: '#e5e1e4'
  inverse-on-surface: '#313032'
  outline: '#849495'
  outline-variant: '#3b494b'
  surface-tint: '#00dbe9'
  primary: '#dbfcff'
  on-primary: '#00363a'
  primary-container: '#00f0ff'
  on-primary-container: '#006970'
  inverse-primary: '#006970'
  secondary: '#ecb2ff'
  on-secondary: '#520071'
  secondary-container: '#cf5cff'
  on-secondary-container: '#480063'
  tertiary: '#f3f6ff'
  on-tertiary: '#28313f'
  tertiary-container: '#d1daec'
  on-tertiary-container: '#565f6f'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#7df4ff'
  primary-fixed-dim: '#00dbe9'
  on-primary-fixed: '#002022'
  on-primary-fixed-variant: '#004f54'
  secondary-fixed: '#f8d8ff'
  secondary-fixed-dim: '#ecb2ff'
  on-secondary-fixed: '#320047'
  on-secondary-fixed-variant: '#74009f'
  tertiary-fixed: '#dae3f5'
  tertiary-fixed-dim: '#bec7d9'
  on-tertiary-fixed: '#131c29'
  on-tertiary-fixed-variant: '#3e4756'
  background: '#131315'
  on-background: '#e5e1e4'
  surface-variant: '#353437'
typography:
  display-lg:
    fontFamily: Space Grotesk
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Space Grotesk
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
  headline-md:
    fontFamily: Space Grotesk
    fontSize: 24px
    fontWeight: '500'
    lineHeight: 32px
  body-lg:
    fontFamily: Geist
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Geist
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  code-sm:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '450'
    lineHeight: 20px
  label-xs:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  xxl: 64px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 40px
---

## Brand & Style
The design system is centered on the concept of **Cognitive Layers**, visualizing the hierarchy of AI memory. It targets developers and system architects who require high-density information without cognitive fatigue. The style is a hybrid of **Minimalist-Futurism** and **Glassmorphism**, emphasizing the depth of neural pathways. 

The aesthetic evokes a sense of "Semantic Efficiency"—where every pixel serves a functional purpose in mapping thought patterns. The UI should feel like a high-performance instrument: precise, deep, and intellectually stimulating. We utilize translucent layers to represent different depths of the xAI memory stack, creating a workspace that feels like a digital extension of the user's mind.

## Colors
The palette is rooted in a deep "Obsidian" neutral to minimize eye strain and maximize the vibrancy of the functional accents.

*   **Primary (Cyan):** Represents 'Permanent Memory'. It is used for stable data, long-term storage indicators, and foundational system states.
*   **Secondary (Purple):** Represents 'Ephemeral Context'. It is used for real-time processing, temporary session data, and transient neural activations.
*   **Tertiary (Slate):** Used for metadata, technical annotations, and inactive states.
*   **Semantic Logic:** Use the Cyan/Purple distinction strictly to indicate data persistence. Mixing these colors signals a transition from context to long-term memory.

## Typography
The typography system balances technical precision with high readability. 

*   **Space Grotesk** is reserved for headlines and data headers, providing a geometric, futuristic character that reflects the xAI identity.
*   **Geist** serves as the workhorse for all body text and descriptions, offering a clean, minimal, and developer-friendly sans-serif experience.
*   **JetBrains Mono** is utilized for labels, technical metadata, and memory addresses, reinforcing the "Semantic Efficiency" narrative.
*   **Mobile Scaling:** Headlines above 32px should scale down by 25% on mobile devices to maintain layout integrity.

## Layout & Spacing
This design system utilizes a **Fixed Grid** model for the dashboard's core layout to ensure predictable data visualization.

*   **Grid:** 12-column system on desktop, 4-column on mobile.
*   **Rhythm:** A 4px baseline grid governs all vertical spacing.
*   **Container:** The main dashboard content is housed in a max-width 1440px container, centered.
*   **Density:** High-density layouts are preferred. Use `md` (16px) for standard element spacing and `sm` (8px) for related data groups.
*   **Adapting:** On mobile, sidebars collapse into a bottom-anchored navigation bar to prioritize the workspace "viewport."

## Elevation & Depth
Depth is communicated through **Tonal Layering** and **Subtle Glassmorphism**. We avoid traditional shadows in favor of light-based depth.

1.  **Base (Level 0):** Pure black (#000) for the background.
2.  **Surface (Level 1):** Obsidian (#121214) with a 1px border (#27272A).
3.  **Active Overlay (Level 2):** Semi-transparent surfaces (10% opacity white) with a 20px backdrop blur to create a sense of "focus" on specific memory segments.
4.  **Semantic Glow:** Instead of shadows, active elements use a faint outer glow matching the functional color (Cyan for permanent, Purple for ephemeral) with a 15% opacity.

## Shapes
The shape language is "Soft-Technical." Elements are predominantly rectangular with subtle 0.25rem (4px) rounding to maintain a professional, architectural feel. 

*   **Standard Elements:** 4px radius.
*   **Large Cards/Sections:** 8px radius.
*   **Interactive Inputs:** 4px radius.
*   **Pill Indicators:** Used only for status badges (e.g., "Active," "Cached") to differentiate them from functional buttons.

## Components
Consistent styling of the Cognitive Horizon toolkit:

*   **Buttons:** Rectangular with 4px radius. Primary buttons use a ghost style with a solid 1px Cyan border. Secondary buttons use a Purple border. Hover states should fill the button with a 10% tint of the border color.
*   **Memory Chips:** Small labels with a background tint. Permanent chips are Cyan text on 10% Cyan background; Ephemeral chips are Purple text on 10% Purple background.
*   **Input Fields:** Dark background (#09090B) with a subtle bottom-border (1px) that glows Primary Cyan on focus. Use JetBrains Mono for input text.
*   **Memory Cards:** Use Level 1 Surface styling. The top edge of the card should feature a 2px horizontal line in either Cyan or Purple to immediately denote the memory type.
*   **Neural Lists:** Lists should use monospaced addresses for bullets. Items are separated by low-contrast lines (#27272A).
*   **Trace Lines:** Use thin, 1px dashed lines to connect related memory nodes, using a gradient from Purple to Cyan to show context being "baked" into permanent storage.