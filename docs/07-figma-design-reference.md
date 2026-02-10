# Figma Design Reference

## Design File Information

**Figma File**: Recipe and Shopping Organizer  
**File ID**: `zYcBkRQoCvYTxrCIS8yiHZ`  
**Link**: [View in Figma](https://www.figma.com/make/zYcBkRQoCvYTxrCIS8yiHZ/Recipe-and-Shopping-Organizer?fullscreen=1&t=n9UskWVIBXlHV4cO-1)

## Design System Overview

Based on the Figma design, this document outlines the UI components, styles, and patterns used throughout the application.

## Color Palette

### Primary Colors
- **Orange/Tangerine**: Primary action color (buttons, accents)
  - Used for: "Nouvelle recette" button, "Coriger l'orthographe" button
  - Appears vibrant and energetic
  
- **Pink/Magenta**: Secondary action color
  - Used for: "Depuis un lien" button, "Transcrire la recette" button
  - Creates visual hierarchy for video import feature

- **Blue**: Information and navigation
  - Used for: "Gérer catégories" button, category management modal header
  - Lighter blue for informational text

### Neutral Colors
- **White**: Primary background, card backgrounds
- **Light Beige/Cream**: Secondary backgrounds, meal planning slots
- **Dark Gray/Black**: Primary text
- **Medium Gray**: Secondary text, placeholders
- **Light Gray**: Borders, dividers

### Accent Colors
- **Category Colors**: Soft pastels for recipe category cards
  - Pale yellow for "Plats" category
  - Light peach for "Pains" category
  - Soft beige for "Desserts" and "Soupes"
  - Light gray for "Jus" and "Snacks"

## Typography

### Font Family
The design appears to use a clean sans-serif font (likely system font):
- iOS: SF Pro / San Francisco
- Android: Roboto

### Text Styles

**Headings**
- **H1 (Page Title)**: Large, bold - "Mes Recettes" at top
- **H2 (Section Title)**: Medium-large, semi-bold - "Gérer les catégories"
- **H3 (Card Title)**: Medium, regular - Recipe category names

**Body Text**
- **Regular**: Recipe counts, descriptions
- **Small**: Helper text, timestamps ("1 recette", "il y a 2hr")

**Labels**
- **Form Labels**: Medium, semi-bold - "Titre", "Catégorie", "Ingrédients"
- **Button Labels**: Medium, semi-bold - Action text on buttons

## UI Components

### 1. Tabs (Top Navigation)

**Structure:**
- Two tabs: "🍳 Recettes" and "📅 Planning"
- Active tab has orange underline
- Icons + text labels

**States:**
- Active: Bold text, orange underline
- Inactive: Regular text, no underline

**Implementation Notes:**
- Fixed to top of screen
- Switches between main app sections
- Smooth transition animation

### 2. Action Buttons (Primary)

**Large Orange Button** ("Nouvelle recette")
- Rounded corners (~8-12px radius)
- Orange background
- White text
- Shadow for depth
- Full-width or fixed width positioning

**Large Pink Button** ("Depuis un lien")
- Similar styling to orange button
- Pink/magenta background
- White text
- Used for secondary but important actions

**Small Button** ("+ Ajouter", "+ Ajuster")
- Smaller size
- Orange or transparent background
- Orange text (when transparent)
- Used for inline actions

### 3. Recipe Category Cards

**Card Structure:**
- Square or near-square aspect ratio
- Soft background color (varies by category)
- Centered emoji icon (large, ~48-64px)
- Category name below emoji
- Recipe count below name
- Subtle shadow or border
- Rounded corners (~12-16px)

**Grid Layout:**
- 2 columns on mobile
- Equal spacing between cards
- Responsive to screen width

**Example Categories:**
- 🍽️ Plats (1 recette)
- 🍞 Pains (1 recette)
- 🍰 Desserts (1 recette)
- 🥤 Jus (1 recette)
- 🍿 Snacks (8 recettes)
- 🍲 Soupes (6 recettes)

### 4. Category Management Modal

**Header:**
- Blue background
- White text: "Gérer les catégories"
- Close button (X) on top right

**Content Area:**
- White background
- Section title: "Ajouter une catégorie"
- Input field with emoji picker
- List of "Catégories existantes"

**Category List Items:**
- Checkbox for selection
- Emoji icon
- Category name
- Removable/editable

### 5. Video Import Modal

**Header:**
- Pink/magenta gradient background
- Icon (link symbol)
- Title: "Importer depuis un lien"
- Subtitle: "Collez un lien de vidéo TikTok, Instagram, YouTube..."

**Input Section:**
- Text label: "Lien de la vidéo"
- URL input field with placeholder
- Platform suggestion buttons (TikTok, Instagram, YouTube, Facebook)

**Action Button:**
- Full-width pink button
- Icon + text: "✨ Transcrire la recette"
- Bottom of modal

**Cancel Action:**
- Text button "Annuler" at bottom
- Transparent background

### 6. Recipe Creation Form

**Header:**
- Orange background
- Title: "Nouvelle recette"

**Form Fields:**
- **Titre**: Single-line text input with placeholder
- **Catégorie**: Dropdown selector (shows "Plats" in example)
- **Mot-clé pour l'usage**: Multi-line text input with placeholder
- **Ingrédients**: 
  - Multi-entry field
  - "+ Ajouter" button to add more
  - Shows "Ingrédient 1", "Ingrédient 2", etc.
- **Préparation**:
  - Multi-step field
  - Each step labeled "Étape 1", "Étape 2", etc.
  - "+ Ajouter" button for additional steps

**Submit Button:**
- Pink button at bottom
- Text: "📸 Coriger l'orthographe" (Note: Appears to be "Corriger l'orthographe")

### 7. Meal Planning Calendar

**Structure:**
- Weekly view (7 days)
- Day names as row headers: Jour, Lundi, Mardi, Mercredi, Jeudi, Vendredi, Samedi, Dimanche
- Two meal columns: "Petit-déj / Déjeuner" and "Snack / Dîner"
- Alternative view: "Snack / Dîner" column

**Empty State:**
- Light beige/cream background in each cell
- "+ Ajouter" button centered
- Subtle dashed border

**Filled State (with recipe):**
- Recipe card in cell
- Shows recipe emoji and name
- Light colored background
- Example: "🥗 Snack" and "🍽️ Dîner"

**Recipe Tooltip/Hover:**
- Dark overlay popup
- Shows multiple recipe options:
  - "Poulet Rôti aux Herbes (Plats)"
  - "Pain de campagne (Pains)"
  - "Tarte aux pommes (Desserts)"
  - "Smoothie tropical (Jus)"
- Appears when hovering/clicking meal slot

### 8. Shopping List Section

**Generator Card:**
- White background
- Shopping cart icon
- Title: "Générer la liste de courses"
- Subtitle: "Créer votre liste basée sur le menu de la semaine"
- Number input: "Nombre de personnes" with stepper (4 personnes)
- Orange button: "🛒 Générer la liste"

**Shopping List View:**
- Header: "Liste de courses"
- Subtitle: "Pour 4 personnes • 4 articles restants"
- Checkbox list items:
  - ☐ 500g de farine
  - ☐ 1kg de sel
  - ☐ 7g de levure
  - ☐ 30cm³ d'eau tiède
- Close button (X)

**Week Navigation:**
- Arrow buttons to move between weeks
- Week display: "Jeudi / Vendredi / Samedi / Dimanche"

**Planning Link:**
- Info icon + text
- "Ajoutez des recettes au planning pour générer votre liste de courses"

## Layout Patterns

### 1. Screen Layout

**Standard Screen Structure:**
```
┌─────────────────────────────┐
│ Top Navigation (Tabs)       │
├─────────────────────────────┤
│ Page Title                  │
│ Action Buttons              │
├─────────────────────────────┤
│                             │
│ Main Content Area           │
│ (Grid/List/Calendar)        │
│                             │
└─────────────────────────────┘
```

### 2. Modal Layout

**Modal Structure:**
```
┌─────────────────────────────┐
│ Colored Header with Title  │X│
├─────────────────────────────┤
│                             │
│ Content Area                │
│ (Forms/Lists/Info)          │
│                             │
├─────────────────────────────┤
│ Primary Action Button       │
│ Cancel Button (Text)        │
└─────────────────────────────┘
```

### 3. Card Grid Layout

**Recipe Categories Grid:**
```
┌──────────┐  ┌──────────┐
│ Category │  │ Category │
│   Card   │  │   Card   │
└──────────┘  └──────────┘

┌──────────┐  ┌──────────┐
│ Category │  │ Category │
│   Card   │  │   Card   │
└──────────┘  └──────────┘
```

## Spacing System

Based on the design, the spacing appears to follow a consistent scale:

- **XXS**: 4px - Icon padding, tight spacing
- **XS**: 8px - Between text elements
- **S**: 12px - Between related items
- **M**: 16px - Between components
- **L**: 24px - Between sections
- **XL**: 32px - Page margins
- **XXL**: 48px - Large gaps

## Border Radius

- **Small**: 4-8px - Input fields, small buttons
- **Medium**: 12-16px - Cards, large buttons
- **Large**: 20-24px - Modals, prominent elements

## Icons

### Icon Style
- Simple, outlined style (line icons)
- Emoji used for categories and visual interest
- Standard system icons for common actions

### Icon Sizes
- **Small**: 16px - Inline icons
- **Medium**: 24px - Button icons
- **Large**: 32-48px - Feature icons
- **XL**: 64px+ - Category emoji icons

## Shadows

### Card Shadow
- Subtle shadow for depth
- Approximately: `0 2px 8px rgba(0, 0, 0, 0.1)`

### Button Shadow
- Light shadow for raised appearance
- Approximately: `0 2px 4px rgba(0, 0, 0, 0.08)`

### Modal Shadow
- Stronger shadow for prominence
- Approximately: `0 8px 24px rgba(0, 0, 0, 0.15)`

## Responsive Breakpoints

Based on mobile-first design:

- **Mobile**: 320px - 767px (primary target)
- **Tablet**: 768px - 1023px
- **Desktop**: 1024px+ (web version)

## Animations & Transitions

### Recommended Transitions
- **Fade In**: Modals, overlays (300ms ease)
- **Slide Up**: Modals from bottom (250ms ease-out)
- **Scale**: Button press feedback (150ms ease)
- **Color**: Hover states (200ms ease)
- **Transform**: Tab switching (300ms ease-in-out)

## Accessibility Considerations

### Color Contrast
- Ensure text has sufficient contrast against backgrounds
- Orange buttons with white text: Good contrast
- Light text on light backgrounds: Need to verify

### Touch Targets
- Minimum 44x44px for tappable elements
- Adequate spacing between clickable items
- Large buttons for primary actions

### Form Accessibility
- Labels for all inputs
- Error states with clear messaging
- Keyboard navigation support

## Implementation Guidelines

### CSS Framework Recommendation
Given the design style, recommended approaches:

**Option 1: Tailwind CSS**
- Quick implementation of spacing, colors
- Utility-first matches the design's simplicity
- Easy responsive design

**Option 2: Styled Components (React)**
- Component-scoped styling
- Dynamic theming support
- JavaScript-based styling

**Option 3: CSS Modules**
- Scoped styles
- Standard CSS syntax
- Good for traditional approach

### Design Tokens

Create a design token file for consistency:

```javascript
// tokens.js
export const colors = {
  primary: {
    orange: '#FF8C42',
    pink: '#E74C9A',
    blue: '#4A90E2'
  },
  neutral: {
    white: '#FFFFFF',
    cream: '#FFF8F0',
    lightGray: '#F5F5F5',
    mediumGray: '#999999',
    darkGray: '#333333',
    black: '#000000'
  },
  category: {
    plats: '#FFF8DC',
    pains: '#FFE4C4',
    desserts: '#FFF0E6',
    jus: '#F0F0F0',
    snacks: '#FFE4E1',
    soupes: '#FAF0E6'
  }
};

export const spacing = {
  xxs: '4px',
  xs: '8px',
  s: '12px',
  m: '16px',
  l: '24px',
  xl: '32px',
  xxl: '48px'
};

export const borderRadius = {
  small: '8px',
  medium: '12px',
  large: '20px'
};

export const shadows = {
  card: '0 2px 8px rgba(0, 0, 0, 0.1)',
  button: '0 2px 4px rgba(0, 0, 0, 0.08)',
  modal: '0 8px 24px rgba(0, 0, 0, 0.15)'
};
```

## Component Implementation Priority

### Phase 1: Core Components
1. ✅ Tab Navigation
2. ✅ Recipe Category Card
3. ✅ Primary Buttons (Orange, Pink)
4. ✅ Input Fields

### Phase 2: Complex Components
5. ✅ Category Management Modal
6. ✅ Video Import Modal
7. ✅ Recipe Form
8. ✅ Meal Planning Calendar

### Phase 3: Advanced Features
9. ✅ Shopping List Generator
10. ✅ Recipe Tooltip/Popup
11. ✅ List with Checkboxes

## Design Assets Export

### From Figma
When exporting from Figma:

1. **Icons**: Export as SVG (24x24, 32x32)
2. **Emoji**: Can use system emoji or export as PNG
3. **Buttons**: Export as components with states
4. **Colors**: Extract hex codes for design tokens
5. **Spacing**: Measure in Figma for exact values

### Image Optimization
- Compress recipe images (WebP format recommended)
- Use responsive images (multiple sizes)
- Lazy load images below fold
- Optimize emoji/icon file sizes

## Notes from Design Analysis

### Design Strengths
✅ Clean, modern interface  
✅ Clear visual hierarchy  
✅ Consistent color usage  
✅ Good use of whitespace  
✅ Emoji make categories memorable  
✅ Intuitive iconography  

### Considerations for Development
⚠️ Ensure adequate spacing on smaller screens  
⚠️ Test color contrast for accessibility  
⚠️ Plan for long recipe/category names  
⚠️ Consider loading states for all async operations  
⚠️ Add skeleton screens for better perceived performance  

### Suggested Enhancements (Optional)
💡 Add subtle animations for better UX  
💡 Consider dark mode variant  
💡 Add swipe gestures for mobile (meal planning)  
💡 Implement drag-and-drop for meal slots  
💡 Add image previews in recipe cards  

## Figma File Structure

The Figma file contains multiple frames showing:

1. **Recipes Tab Views**
   - Category grid view
   - Category management

2. **Video Import Flow**
   - Import modal with platform selection

3. **Recipe Creation**
   - Multi-step form with all fields

4. **Planning Tab Views**
   - Weekly calendar (multiple variations)
   - Empty state
   - Filled state with recipes
   - Recipe tooltip overlay

5. **Shopping List Views**
   - Generator interface
   - Generated list view
   - Week navigation

## Using Figma MCP for Development

With the Figma MCP server installed, you can:

1. **Extract Design Context**
   ```
   Select a frame in Figma → Ask agent to "generate code for my Figma selection"
   ```

2. **Get Component Code**
   ```
   Select button component → "generate React component with Tailwind CSS"
   ```

3. **Extract Colors and Spacing**
   ```
   Select elements → "get the variables and styles used in my selection"
   ```

4. **Generate Consistent Components**
   - Set up Code Connect mappings
   - Reuse actual components from your codebase
   - Maintain design system consistency

## Next Steps

1. ✅ Review all Figma frames
2. ✅ Extract exact color values from Figma
3. ✅ Create design token file
4. ✅ Export needed assets (icons, images)
5. ✅ Set up component library based on designs
6. ✅ Implement one screen at a time following designs
7. ✅ Test responsiveness at different breakpoints

---

**Figma Link**: [Recipe and Shopping Organizer Design](https://www.figma.com/make/zYcBkRQoCvYTxrCIS8yiHZ/Recipe-and-Shopping-Organizer?fullscreen=1&t=n9UskWVIBXlHV4cO-1)

**Design Version**: 1.0  
**Last Updated**: February 7, 2026  
**Screens**: 13+ frames covering all main flows
