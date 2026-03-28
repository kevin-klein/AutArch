/**
 * Internationalization (i18n) Utility
 * Supports English (en) and German (de)
 */

// Translation dictionaries
const translations = {
  en: {
    // Common
    continue: 'Continue',
    back: 'Back',
    next: 'Next',
    loading: 'Loading...',
    error: 'Error',
    select: 'Select',
    upload: 'Upload',
    image: 'Image',
    file: 'File',
    analysis: 'Analysis',

    // Wizard
    step: 'Step',
    of: 'of',
    ceramicAnalysis: 'Ceramic Analysis',
    completingAnalysis: 'Completing Analysis',
    ceramicAnalysisMessage: 'Your ceramic analysis is being completed.',

    // Upload Step
    uploadImage: 'Upload Image',
    howToUse: 'How to use this:',
    similarity: 'Similarity:',
    objectUpload: 'Object Upload',
    uploadInstructions: 'Drag & drop an image file (JPG, PNG, GIF, WebP) or click to browse your files. Maximum size is 10MB recommended.',
    selectVessel: 'Select Vessel',
    selectVesselInstructions: 'Select a vessel for comparison to other vessels.',
    similarityInstructions: 'View similar objects and a 3D model of the vessel.',
    reviewFeatures: 'Review Features',
    reviewFeaturesInstructions: 'The interface will auto-detect object types for you, but you will have the chance to adjust this later in the workflow.',
    continueInstructions: 'Once your file is selected and ready, click the "Continue" button to proceed to the next step.',
    objectTypeInfo: 'Choose the type of artifact (Lithics, Graves, Arrowheads, or Ceramics) you are adding.',
    lithics: 'Lithics - Stone tools',
    graves: 'Graves - Burial pits',
    arrowheads: 'Arrowheads - Lithic Arrowheads',
    ceramics: 'Ceramics - Pottery and ceramic artifacts',
    supports: 'Supports:',
    max: 'Max:',
    selectFile: 'select a file',
    fileSelected: 'file selected',
    sourceImage: 'Source Image',
    demoFile: 'demo.jpg',
    dragImage: 'Drag the image above here to continue',
    dragDrop: 'Drag & drop an image file here',
    orClick: 'or click to browse',

    // Select Ceramic
    selectCeramicContours: 'Select Ceramic Contours',
    clickContour: 'Click on a contour to select it. Selected contours will be highlighted in blue.',
    usageHints: 'Usage Hints',
    singleSelect: 'Single Select',
    singleSelectDesc: 'Click a contour to select it (it becomes blue)',
    multiSelect: 'Multi-Select',
    multiSelectDesc: 'Click multiple contours from the same figure',
    changeFigure: 'Change Figure',
    changeFigureDesc: 'Click a different figure to switch selection',
    figureInfo: 'Figure Info',
    figureInfoDesc: 'Hover over a figure to see its details',
    contourViewer: 'Contour Viewer',
    recommended: 'Recommended',
    selectedFigure: 'Selected Figure',
    figureDetails: 'Figure Details',
    type: 'Type',
    identifier: 'Identifier',
    site: 'Site',
    figures: 'Figures',
    noFigures: 'No figures available',
    howToUseTitle: 'How to Use',
    scrollFigures: 'Scroll through the figures list to see all available ceramics',
    clickFigure: 'Click on any figure to select it',
    clickContours: 'Click on contours in the image to select specific ones',
    selectedContours: 'Selected contours appear in blue with vertex circles',
    viewDetails: 'View figure details in the sidebar',
    processing: 'Processing...',

    // Similarity Step
    similarityAnalysis: 'Similarity Analysis',
    comparingWith: 'Comparing',
    withOtherVessels: 'with other vessels from the same publication',
    similarVessels: 'Similar Vessels',
    maxSimilarity: 'Max Similarity',
    publication: 'Publication',
    originalVessel: 'Original Vessel',
    backToAnalysis: 'Back to Selection',
    nextAnalysis: 'Done',
    detailedComparison: 'Detailed Comparison',
    selectedCeramic: 'Selected Ceramic',
    originalCeramic: 'Original Ceramic',
    ceramicDetails: 'Ceramic Details',
    similarityScore: 'Similarity Score',
    page: 'Page',
    detectionConfidence: 'Detection Confidence',
    verySimilar: 'Very Similar',
    moderatelySimilar: 'Moderately Similar',
    lessSimilar: 'Less Similar',
    errorLoadingSimilarities: 'Error Loading Similarities',
    noSimilarityData: 'No Similarity Data Available',
    similarityDataNotComputed: 'Similarity data has not been computed for this publication yet.',
    pleaseSelectFigure: 'Please select a figure first',
    figureNotFound: 'Selected figure not found',

    // Language Selection
    selectLanguage: 'Select Language',
    languageInstructions: 'Please choose your preferred language',
    english: 'English',
    german: 'Deutsch',
    germanEnglish: 'German / English',

    // PLY Viewer
    threeDControls: '3D Controls',
    resetView: 'Reset View',
    pauseAutoRotate: 'Pause Auto-Rotate',
    autoRotate: 'Auto-Rotate',
    mouseRotate: 'Left-click: Rotate',
    mousePan: 'Right-click: Pan',
    mouseZoom: 'Scroll: Zoom'
  },
  de: {
    // Common
    continue: 'Weiter',
    back: 'Zurück',
    next: 'Weiter',
    loading: 'Laden...',
    error: 'Fehler',
    select: 'Auswählen',
    upload: 'Hochladen',
    image: 'Bild',
    file: 'Datei',
    analysis: 'Analyse',

    // Wizard
    step: 'Schritt',
    of: 'von',
    ceramicAnalysis: 'Keramik-Analyse',
    completingAnalysis: 'Analyse abgeschlossen',
    ceramicAnalysisMessage: 'Ihre Keramik-Analyse wird abgeschlossen.',

    // Upload Step
    uploadImage: 'Bild hochladen',
    similarity: 'Ähnlichkeit:',
    howToUse: 'Schritte:',
    objectUpload: 'Objekt-Hochladen',
    uploadInstructions: 'Ziehen Sie eine Bilddatei (JPG, PNG, GIF, WebP) hierher oder klicken Sie, um Ihre Dateien zu durchsuchen. Maximale Größe wird mit 10MB empfohlen.',
    selectVessel: 'Gefäß auswählen',
    selectVesselInstructions: 'Wählen Sie ein Gefäß zum Vergleich mit anderen Gefäßen.',
    similarityInstructions: 'Ähnliche Objekte anzeigen und ein 3D-Modell des Gefäßes.',
    reviewFeatures: 'Funktionen überprüfen',
    reviewFeaturesInstructions: 'Die Schnittstelle erkennt Objekttypen automatisch, aber Sie haben später die Möglichkeit, dies anzupassen.',
    continueInstructions: 'Sobald Ihre Datei ausgewählt und bereit ist, klicken Sie auf die "Weiter"-Schaltfläche, um zum nächsten Schritt zu gelangen.',
    objectTypeInfo: 'Wählen Sie die Art des Artefakts (Lithika, Gräber, Pfeilspitzen oder Keramik), das Sie hinzufügen.',
    lithics: 'Lithika - Steinwerkzeuge',
    graves: 'Gräber - Bestattungsgruben',
    arrowheads: 'Pfeilspitzen - Lithische Pfeilspitzen',
    ceramics: 'Keramik - Töpferwaren und keramische Artefakte',
    supports: 'Unterstützt:',
    max: 'Max:',
    selectFile: 'Datei auswählen',
    fileSelected: 'Datei ausgewählt',
    sourceImage: 'Quellbild',
    demoFile: 'demo.jpg',
    dragImage: 'Ziehen Sie das Bild auf die vorgesehene Fläche',
    dragDrop: 'Bild hierher ziehen',
    orClick: 'oder klicken zum Durchsuchen',

    // Select Ceramic
    selectCeramicContours: 'Keramik-Konturen auswählen',
    clickContour: 'Klicken Sie auf eine Kontur, um sie auszuwählen. Ausgewählte Konturen werden blau hervorgehoben.',
    usageHints: 'Hinweise',
    contourViewer: 'Konturen-Betrachter',
    recommended: 'Empfohlen',
    selectedFigure: 'Ausgewählte Figur',
    figureDetails: 'Figur-Details',
    type: 'Typ',
    identifier: 'Bezeichnung',
    site: 'Fundort',
    figures: 'Figuren',
    noFigures: 'Keine Figuren verfügbar',
    howToUseTitle: 'Wie man es verwendet',
    scrollFigures: 'Scrollen Sie durch die Figurenliste, um alle verfügbaren Keramikgefäße zu sehen',
    clickFigure: 'Klicken Sie auf eine beliebige Figur, um sie auszuwählen',
    clickContours: 'Klicken Sie auf Konturen im Bild, um spezifische auszuwählen',
    selectedContours: 'Ausgewählte Konturen erscheinen in Blau mit Eckpunktkreisen',
    viewDetails: 'Figur-Details in der Seitenleiste anzeigen',
    processing: 'Verarbeitung...',

    // Similarity Step
    similarityAnalysis: 'Ähnlichkeitsanalyse',
    comparingWith: 'Vergleich',
    withOtherVessels: 'mit anderen Gefäßen derselben Publikation',
    similarVessels: 'Ähnliche Gefäße',
    maxSimilarity: 'Maximale Ähnlichkeit',
    publication: 'Publikation',
    originalVessel: 'Original-Gefäß',
    backToAnalysis: 'Zurück zur Auswahl',
    nextAnalysis: 'Fertig',
    detailedComparison: 'Detaillierter Vergleich',
    selectedCeramic: 'Ausgewählte Keramik',
    originalCeramic: 'Original-Keramik',
    ceramicDetails: 'Keramik-Details',
    similarityScore: 'Ähnlichkeitswert',
    page: 'Seite',
    detectionConfidence: 'Erkennungssicherheit',
    verySimilar: 'Sehr ähnlich',
    moderatelySimilar: 'Mäßig ähnlich',
    lessSimilar: 'Weniger ähnlich',
    errorLoadingSimilarities: 'Fehler beim Laden der Ähnlichkeiten',
    noSimilarityData: 'Keine Ähnlichkeitsdaten verfügbar',
    similarityDataNotComputed: 'Ähnlichkeitsdaten wurden für diese Publikation noch nicht berechnet.',
    pleaseSelectFigure: 'Bitte wählen Sie zuerst eine Figur aus',
    figureNotFound: 'Ausgewählte Figur nicht gefunden',

    // Language Selection
    selectLanguage: 'Sprache auswählen',
    languageInstructions: 'Bitte wählen Sie Ihre bevorzugte Sprache',
    english: 'English',
    german: 'Deutsch',
    germanEnglish: 'Deutsch / Englisch',

    // PLY Viewer
    threeDControls: '3D-Steuerung',
    resetView: 'Ansicht zurücksetzen',
    pauseAutoRotate: 'Auto-Rotation pausieren',
    autoRotate: 'Auto-Rotation',
    mouseRotate: 'Linksklick: Drehen',
    mousePan: 'Rechtsklick: Verschieben',
    mouseZoom: 'Scrollen: Zoom'
  }
}

// Default language
let currentLanguage = 'en'

// Set language
export function setLanguage (lang) {
  if (translations[lang]) {
    currentLanguage = lang
    return true
  }
  return false
}

// Get current language
export function getLanguage () {
  return currentLanguage
}

// Get translation
export function t (key) {
  const keys = key.split('.')
  let value = translations[currentLanguage]

  for (const k of keys) {
    if (value && value[k] !== undefined) {
      value = value[k]
    } else {
      // Fall back to English
      value = translations.en
      for (const k2 of keys) {
        if (value && value[k2] !== undefined) {
          value = value[k2]
        } else {
          return key
        }
      }
      break
    }
  }

  return value || key
}

// Get available languages
export function getLanguages () {
  return [
    { code: 'en', name: 'English', flag: '🇬🇧' },
    { code: 'de', name: 'Deutsch', flag: '🇩🇪' }
  ]
}
