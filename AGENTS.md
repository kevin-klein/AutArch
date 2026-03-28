# AutArch Project

## Overview
AutArch is a publication analysis system for archaeological data, specifically focused on processing and analyzing figures (artifacts) from archaeological publications.

## Technology Stack
- **Framework**: Ruby on Rails
- **Database**: PostgreSQL
- **Image Processing**: OpenCV (via MinOpenCV)
- **ML Integration**: Python microservice for BOVW (Bag of Visual Words) training and similarity computation
- **Python Microservice**: `scripts/torch_service.py` (runs on port 9000)
- **esbuild**: in package.json there is a build task

---

## Python Microservice (scripts/torch_service.py)

### Overview
The Python microservice is a Bottle-based Flask-like web service that provides machine learning capabilities for image analysis. It runs on port 9000 by default and is used by the Rails application to process images and extract features.

### Endpoints

#### POST `/`
**Purpose**: Analyze an image for object detection
**Request**: Form data with `image` field (file upload)
**Response**: JSON with predictions
```json
{
  "predictions": [
    {
      "score": 0.95,
      "box": [x1, y1, x2, y2],
      "label": "ClassName"
    }
  ]
}
```
**Model**: FCOS ResNeXt (models/fcos_resnext.model)
**Device**: CUDA if available, otherwise CPU

#### POST `/segment`
**Purpose**: Segment image using SAM (Segment Anything Model) based on user-provided points
**Request**: Form data with `image` and `points` fields
- `image`: File upload
- `points`: JSON string of coordinates `[[x1, y1], [x2, y2], ...]`
**Response**: JSON with contour information
```json
{
  "predictions": {
    "score": 0.98,
    "contour": [[[x1, y1], [x2, y2], ...], [[x1, y1], [x2, y2], ...]]
  }
}
```
**Model**: Mobile SAM (models/mobile_sam.pt)
**Use Case**: Manual contour extraction for figures

#### POST `/arrow`
**Purpose**: Analyze arrow orientation in an image
**Request**: Form data with `image` field
**Response**: JSON with arrow angle prediction
```json
{
  "predictions": [cos, sin]
```
**Model**: Arrow ConvNeXt (models/arrow_convnext.model)
**Use Case**: Determine arrow direction/grave orientation

#### POST `/skeleton`
**Purpose**: Classify skeleton orientation (left/right/standing)
**Request**: Form data with `image` field
**Response**: JSON with skeleton classification
```json
{
  "predictions": "left" | "right" | "standing" | "unknown"
```
**Model**: ConvNeXt Tiny (models/skeleton_convnext_tiny.model)
**Labels**: Loaded from models/skeleton_resnet_labels.model

#### POST `/efd`
**Purpose**: Compute Elliptic Fourier Descriptors (EFD) for a contour
**Request**: JSON body
```json
{
  "contour": [[x1, y1], [x2, y2], ...],
  "order": 15,
  "normalize": true,
  "return_transformation": false
}
```
**Response**: JSON with EFD coefficients
```json
{
  "efds": [coefficients...]
```
**Library**: pyefd

#### POST `/train_bovw`
**Purpose**: Train a new Bag of Visual Words vocabulary and compute similarity matrix
**Request**: JSON body
```json
{
  "images": ["path/to/image1.jpg", "path/to/image2.jpg", ...],
  "n_clusters": 128,
  "feature_type": "sift"
}
```
**Response**: JSON with training results
```json
{
  "success": true,
  "n_clusters": 128,
  "feature_type": "sift",
  "n_images": 50,
  "similarity_matrix": [[0.1, 0.8, ...], ...]
```
**Models**: Uses MiniBatchKMeans for clustering features extracted via SIFT
**Use Case**: BOVW training for ceramic similarity analysis

### Models Loaded

1. **FCOS ResNeXt** (`models/fcos_resnext.model`)
   - Object detection for figure classification
   - Labels loaded from `models/faster_rcnn_v2.model`
   - Classes: Arrow, Skeleton, Grave, Kurgan, Oxcal, Bone, StoneTool, etc.

2. **Mobile SAM** (`models/mobile_sam.pt`)
   - Segment Anything Model for contour extraction
   - Model type: vit_t (tiny)

3. **Arrow ConvNeXt** (`models/arrow_convnext.model`)
   - Predicts arrow orientation (cos, sin values)

4. **Skeleton ConvNeXt Tiny** (`models/skeleton_convnext_tiny.model`)
   - Classifies skeleton deposition type

5. **BOVW Vocabulary** (`models/bovw_vocabulary.pkl`)
   - Pre-trained vocabulary for semantic visual words
   - Used for ceramic similarity computation

### Helper Functions

- `extract_local_features(image_array, feature_type='sift')`: Extracts SIFT or ORB features
- `train_visual_vocabulary(image_paths, n_clusters, feature_type)`: Trains K-Means vocabulary
- `compute_bovw_features(image_array, vocabulary, feature_type)`: Computes BOVW histogram
- `object_features(file, vocabulary)`: Extracts features (BOVW or backbone)
- `analyze_file(file)`: Object detection analysis
- `analyze_arrow(file)`: Arrow orientation analysis
- `analyze_skeleton(file)`: Skeleton classification
- `save_masks_as_images(masks, output_dir)`: Saves SAM masks as images

### Environment
- **Development**: `app.run(debug=True, reloader=True, host='0.0.0.0', port=9000)`
- **Production**: `app.run(host='127.0.0.1', port=9000, server='waitress')`
- **Environment Variable**: `RAILS_ENV` controls production mode

---

## Rails Routes

### Authentication
```ruby
GET    /login                    → user_sessions#login
GET    /logout                   → user_sessions#logout
POST   /login                    → user_sessions#code
POST   /login_code               → user_sessions#login_code
```

### GraphQL
```ruby
POST   /graphql                  → graphql#execute
```

### Users
```ruby
resources :users
```

### Periods
```ruby
resources :periods
```

### Bones
```ruby
resources :bones
```

### Y-Haplogroups
```ruby
resources :y_haplogroups
```

### Mt-Haplogroups
```ruby
resources :mt_haplogroups
```

### Genetics
```ruby
resources :genetics
```

### Anthropologies
```ruby
resources :anthropologies
```

### Cultures
```ruby
resources :cultures
```

### Taxonomies
```ruby
resources :taxonomies
```

### Tags
```ruby
resources :tags
```

### Chronologies
```ruby
resources :chronologies do
  resources :c14_dates
end
```

### Arrow Heads
```ruby
resources :arrow_heads
```

### Size Figures (Figures)
```ruby
# Figure browsing with figure type filtering
GET    /figures/:figure_type    → size_figures#index
DELETE /figures/:figure_type/:id → size_figures#destroy

resources :size_figures do
  resources :update_size_figure

  # Actions on update_size_figure collection
  get :sam_contour

  # Actions on size_figures collection
  collection do
    post :boxes       # Detect object in image
    post :update_contour
    post :new_box
  end
end
```

### Teams
```ruby
resources :teams do
  # User assignments
  resources :team_memberships, only: [:new, :create, :destroy], module: :teams

  # Publication assignments
  resources :team_publications, only: [:new, :create, :destroy], module: :teams
end
```

### Kiosk Config
```ruby
resources :kiosk_configs do
    # Global kiosk config (single record)
    get '/kiosk_config', to: 'kiosk_configs#kiosk_config', as: :kiosk_config
    get '/kiosk_config.json', to: 'kiosk_configs#show', as: :kiosk_config_json
    get '/kiosk_config/frontend', to: 'kiosk_configs#kiosk_config_frontend', as: :kiosk_config_frontend
    get '/select_ceramic', to: 'kiosk_configs#select_ceramic', as: :select_ceramic

    # JSON API for page selection
    get '/kiosk_config/pages.json', to: 'kiosk_configs#pages', as: :kiosk_pages

    # JSON API for publications
    get '/kiosk_config/publications.json', to: 'kiosk_configs#publications', as: :kiosk_publications

    # JSON API for figures on a page
    get '/kiosk_config/pages/:id/figures.json', to: 'kiosk_configs#page_figures', as: :kiosk_page_figures
  end
```

**Frontend**: React component at `app/javascript/components/KioskConfig.js` and `app/javascript/components/SelectCeramic.js`
**Views**:
- `/kiosk_config/frontend` - Kiosk Config interface
- `/kiosk_configs/select_ceramic` - Select Ceramic Contours interface
**Mount**: Via `data-react-component` attribute
**CSS**: `app/assets/stylesheets/kiosk_config.css` and `app/assets/stylesheets/select_ceramic.css`

**SelectCeramic Features**:
- Interactive contour selection (click to select, multi-select support)
- Recommended figure highlighting from `/kiosk_configs/kiosk_config.json`
- Next button to proceed to next step in workflow
- Simplified figure details (identifier, site, probability, contour points)
- Visual indicators: blue selection, orange recommended, indigo hover
- Responsive design with Bootstrap 5

### LocationMap
```ruby
resources :location_maps do
  get '/location_map', to: 'location_maps#location_map', as: :location_map
end
```

**Component**: `app/javascript/components/LocationMap.js`
**View**: `/location_maps/location_map`
**Mount**: Via `data-react-component` attribute
**CSS**: `app/assets/stylesheets/location_map.css`

**Features**:
- Full-screen map in modal dialog
- Interactive map display using Leaflet.js
- Click markers to select locations
- Location list overlay (toggleable)
- Legend overlay (toggleable)
- Selected location info overlay
- Auto-zoom based on location count
- Configurable via props
- Red pulsing markers for selected locations
- Green markers for normal locations
- Supports highlighted location parameter

**Props**:
- `locations`: Array of location objects
- `highlightLocation`: Location to highlight
- `height`: Map height (default: 600)
- `initialZoom`: Initial zoom level (default: 6)
- `showPopup`: Enable popup on click (default: true)
- `isOpen`: Show modal (default: true)
- `showCloseButton`: Show header/footer (default: true)
- `showLegend`: Show legend overlay (default: true)
- `showLocationList`: Show location list (default: true)

**Usage**:
```javascript
const locations = [
  { name: 'Site A', lat: 34.12132, lon: 9.551312 },
  { name: 'Site B', lat: 35.23456, lon: 8.987654 }
];

<LocationMap
  locations={locations}
  highlightLocation={highlightedLocation}
/>
```

### Kurgans
```ruby
resources :kurgans
```

### Sites
```ruby
resources :sites
```

### Maps
```ruby
resources :maps
```

### Graves
```ruby
resources :graves do
  resources :update_grave do
    # Actions on update_grave collection
    get :skeleton_keypoints
  end

  # Actions on graves collection
  collection do
    get :stats      # Statistical analysis
    get :orientations
  end

  # Actions on graves member
  member do
    get :related
    post :save_related
  end
end
```

### Figures
```ruby
resources :figures do
  member do
    get :preview    # Generate preview image
  end
end
```

### Skeletons
```ruby
resources :skeletons do
  resources :stable_isotopes
end
```

### Page Images
```ruby
resources :page_images
```

### Ceramics
```ruby
resources :ceramics do
  get :wizard, on: :collection
end

GET    /ceramics/wizard          → ceramics#wizard
```

### Analysis Wizards
```ruby
resources :analysis_wizards do
  member do
    put    :advance_step
    post   :step_1
    post   :step_2
    post   :step_3
    post   :save_ceramic
    post   :similar_ceramics
  end
end
```

### Publications
```ruby
resources :publications do
  resources :pages do
    member do
      post :update_boxes
    end

    collection do
      get :by_page_number
    end
  end

  member do
    # Export operations
    get :export
    get :export_lithics_form
    post :export_lithics

    # Site and tag management
    get :assign_site
    get :assign_tags
    post :update_site
    post :update_tags

    # Analysis operations
    get :progress
    get :stats
    get :analysis
    get :radar
    get :analyze
    get :summary
    get :create_bovw_data
    get :similarities
  end
end
```

### Root
```ruby
root "graves#root"
```

---

## Core Models

### Publication
```ruby
# Attributes: id, author, title, created_at, updated_at, year, user_id, public
# Associations: has_many :pages, has_many :figures, has_many :ceramics, has_one_attached :pdf
# Methods: short_description, graves
```

### Page
```ruby
# Attributes: id, publication_id, number, image_id, created_at, updated_at
# Associations: belongs_to :publication, belongs_to :image, has_many :text_items,
#               has_many :page_texts, has_many :figures, has_many :ceramics, has_many :graves
```

### Figure
```ruby
# Attributes: id, page_id, x1, y2, y1, y2, type, created_at, updated_at, area, perimeter,
#             meter_ratio, angle, parent_id, identifier, width, height, text, site_id,
#             validated, verified, disturbed, contour, deposition_type, publication_id,
#             percentage_scale, page_size, manual_bounding_box, bounding_box_angle,
#             bounding_box_height, bounding_box_width, control_points, anchor_points,
#             probability, contour_info, real_world_area, real_world_width, real_world_height, features
# Associations: belongs_to :page, belongs_to :publication, has_many :key_points,
#               has_one_attached :three_d_model, has_many :similarities_as_first,
#               has_many :similarities_as_second, has_many :related_ceramics,
#               has_and_belongs_to_many :tags
# Methods: manual_contour, box_width, box_height, vector, center, contains?, collides?,
#          distance_to, rotate_bounding_box, rotate_contour, size_ignoring_contour,
#          size_normalized_contour
```

### Grave
```ruby
# Inherits from Figure
# Additional features: skeleton, arrow, site associations
```

### Arrow
```ruby
# Inherits from Figure
# Additional attributes: angle
```

### Skeleton
```ruby
# Inherits from Figure
# Additional features: deposition_type, stable_isotopes
```

### Ceramic
```ruby
# Inherits from Figure
# Additional features: scale, tags, similarities
```

### StoneTool
```ruby
# Inherits from Figure
# Additional features: tags
```

### Image
```ruby
# Attributes: id, created_at, updated_at, width, height
# Associations: belongs_to :page, has_one_attached :data
```

### Site
```ruby
# Attributes: id, name, created_at, updated_at
# Associations: has_many :graves, has_many :figures
```

### Tag
```ruby
# Attributes: id, name, created_at, updated_at
# Associations: has_and_belongs_to_many :figures
```

### Team
```ruby
# Attributes: id, name, created_at, updated_at
# Associations: has_many :team_memberships, has_many :publications, has_many :users
```

---

## Controllers

### PublicationsController
**Key Actions**:
- `index`: List publications with optional sorting
- `create`: Create new publication and trigger analysis
- `create_bovw_data`: Train BOVW vocabulary and compute ceramic similarities
- `similarities`: View ceramic similarity matrix
- `analyze`: EFD PCA analysis for artefacts
- `export_lithics`: Export lithics data
- `export`: Full publication export
- `stats`: Statistical analysis including PCA, heatmaps
- `summary`: Figure type summary

### FiguresController
**Key Actions**:
- `index`: List all figures
- `show`: View figure details
- `create`: Create new figure
- `update`: Update figure
- `destroy`: Delete figure
- `preview`: Generate preview image for figure

### SizeFiguresController
**Key Actions**:
- `index`: List figures with filtering
- `destroy`: Delete figure
- `sam_contour`: Extract contour using SAM
- `update_contour`: Update contour from uploaded image
- `boxes`: Detect objects in image
- `new_box`: Create new figure with SAM contour

### GravesController
**Key Actions**:
- `index`: List graves
- `show`: View grave details
- `stats`: Statistical analysis of graves
- `orientations`: Arrow orientation analysis
- `related`: Find related graves
- `save_related`: Save related grave relationships

### UserSessionsController
**Key Actions**:
- `login`: Show login page
- `logout`: Logout user
- `code`: Handle login with code
- `login_code`: Alternative login method

### GraphQLController
**Key Actions**:
- `execute`: Handle GraphQL queries

---

## Jobs

### AnalyzePublicationJob
**Purpose**: Process uploaded PDF publications
**Workflow**:
1. Convert PDF pages to images
2. Predict figure boxes using ML service
3. Create figures in database
4. Group figures to graves
5. Create lithics
6. Calculate grave angles
7. Measure sizes
8. Analyze contours
9. Analyze scales

---

## Services (app/lib)

### AnalyzePublication
**Purpose**: Main publication analysis logic
**Key Methods**:
- `run(publication, site_id)`: Execute full analysis workflow
- `pdf_to_images(path)`: Convert PDF pages to images
- `predict_boxes(image)`: Call ML service for object detection

### AnalyzeContour
**Purpose**: Extract contours from figures
**Key Methods**:
- `run(figure)`: Extract contour using OpenCV

### AnalyzeContourSam
**Purpose**: Segment and extract contours using SAM
**Key Methods**:
- `run(figure, points)`: Segment figure with user points
- `segment(image, points)`: Call ML service /segment endpoint

### GraveAngles
**Purpose**: Calculate arrow/grave angles
**Key Methods**:
- `run(figures)`: Calculate angles for all arrows
- `arrow_angle(arrow)`: Call ML service /arrow endpoint

### Stats
**Purpose**: Statistical analysis services
**Key Methods**:
- `spine_angles(figures)`: Compute spine angles
- `grave_angles(figures)`: Compute grave angles
- `outlines_pca(figures, options)`: PCA analysis on outlines
- `outlines_efd(figures, options)`: EFD analysis on outlines
- `graves_pca(figures, options)`: PCA on grave shapes

### ExportPublication
**Purpose**: Export publication data
**Key Methods**:
- `export(publication)`: Create export zip file

### ExportLithics
**Purpose**: Export lithic figures
**Key Methods**:
- `export(figures, format, num_points)`: Export as CSV or JSON

### CreateGraves
**Purpose**: Group figures into graves
**Key Methods**:
- `run(pages)`: Create graves from figures

### CreateLithics
**Purpose**: Create lithic figures
**Key Methods**:
- `run(pages)`: Extract lithic figures from pages

### Efd
**Purpose**: Elliptic Fourier Descriptors computation
**Key Methods**:
- `elliptic_fourier_descriptors(contour, options)`: Compute EFD coefficients

---

## Key Features

### Figure Extraction
- Bounding boxes, contours, key points
- Probability scores for detection confidence
- Multiple figure types: Grave, Arrow, Skeleton, Ceramic, StoneTool, etc.

### BOVW Training
- Computes visual similarity between ceramics
- Uses SIFT features with K-Means clustering
- Cosine similarity matrix for ceramic comparison
- Similarity scores stored in ObjectSimilarity model

### Statistical Analysis
- PCA on outlines, grave angles, spine angles
- Heatmaps for deposition type analysis
- Variance analysis for PCA components
- EFD analysis for shape features

### Export
- Lithics export (CSV, JSON)
- Full publication export (ZIP)
- Contour data export

### Tagging & Site Assignment
- Organize figures by sites
- Tag figures for categorization
- Bulk tag assignment
- Site assignment for graves

---

## Ceramic Analysis Wizard

The Ceramic Analysis Wizard is a multi-step React-based workflow for analyzing ceramic artifacts.

### Components

#### CeramicWizard.js
- Main wizard container with step navigation
- Language selection as Step 0
- Supports English and German languages

#### LanguageSelection.js
- Initial language selection screen
- Large flag buttons (🇬🇧 English, 🇩🇪 German)
- Gradient background with animations
- Language persists across wizard steps

#### UploadStep.js
- Image upload with drag & drop
- Object type selection (Lithics, Graves, Arrowheads, Ceramics)
- Demo image support for testing
- Green gradient "Continue" button

#### SelectCeramic.js
- Interactive contour selection
- Recommended figure highlighting
- Multi-select support
- Next button to proceed to similarity analysis

#### SimilarityStep.js
- Displays ceramic similarity analysis
- Original vessel panel with 3D model (PLY viewer)
- Grid layout of similar vessels
- Back button and Next button (page reload)
- Detailed comparison modal

### Shared Components

#### SharedButton.js
- Reusable button component with two variants:
  - **Primary**: Green gradient (`#4caf50` to `#45a049`)
  - **Secondary**: Grey gradient (`#6b7280` to `#4b5563`)
- Hover effects with lift animation
- Disabled state with reduced opacity
- Full width with centered content

### Utilities

#### i18n.js
- Internationalization utility supporting English (en) and German (de)
- Translation keys organized by category:
  - Common, Wizard, Upload Step, Select Ceramic, Similarity Step, Language Selection
- `t()` function for translations with dot notation support
- Fallback to English if German translation is missing
- `setLanguage()`, `getLanguage()`, `getLanguages()` functions

#### idleTimer.js
- Mouse-only idle detection
- Default timeout: 60 seconds (configurable)
- Module-level state for persistence across React re-renders
- `reloadPage()` function for automatic page reload
- `createIdleTimer()` with `onIdle` callback

---

## Workflow

1. **Upload Publication**: User uploads PDF via `/publications` (POST)
2. **Analysis Job**: `AnalyzePublicationJob` processes the PDF
   - Converts PDF to images
   - Detects figures using ML service
   - Creates Figure records
3. **Figure Processing**:
   - Contour extraction using OpenCV
   - Scale analysis
   - Angle calculation for arrows
4. **BOVW Training** (Optional):
   - User triggers `/publications/:id/create_bovw_data`
   - Trains vocabulary with ceramic images
   - Computes similarity matrix
5. **User Review**:
   - Figures reviewed using `update_size_figure` controller
   - Contours refined using SAM segmentation
   - Figure properties edited
6. **Analysis**:
   - Statistical analysis via `/publications/:id/stats`
   - PCA analysis via `/publications/:id/analysis`
   - EFD analysis for shape features
7. **Export**:
   - Lithics export via `/publications/:id/export_lithics`
   - Full publication export via `/publications/:id/export`

---

## Pattern Matching

Pattern matching allows users to identify and match unique small pattern parts across vessel figures.

### Model: PatternPart

**Schema:**
```ruby
create_table :pattern_parts do |t|
  t.references :figure, null: false, foreign_key: true
  t.integer :x1, null: false
  t.integer :y1, null: false
  t.integer :x2, null: false
  t.integer :y2, null: false
  t.text :description
  t.float :confidence, default: 1.0
  t.integer :feature_type, default: 0 # 0: texture, 1: color, 2: edge
  t.jsonb :features, default: {}
end
```

**Attributes:**
- `figure_id`: Parent figure
- `x1, y1, x2, y2`: Bounding box coordinates
- `description`: Optional description (e.g., "Rim decoration")
- `feature_type`: Texture, color, or edge matching

### Workflow

1. **Select Pattern Parts**:
   - Navigate to wizard step: `/publications/:id/ceramics/:figure_id/update_size_figure/select_pattern_parts`
   - Click and drag to draw pattern region boxes
   - Add descriptions and select feature type
   - Save and proceed

2. **View Pattern Matches**:
   - Navigate to: `/size_figures/:id/pattern_matches`
   - Displays query figure with pattern parts
   - Shows matched figures with similarity scores

3. **Python Service**:
   - Endpoint: `POST /pattern_match`
   - Feature types: texture (SIFT), color (LAB histogram), edge (Canny + HOG)
   - Returns matches with similarity scores

### Components

#### PatternPartSelector.js
- React component for pattern part selection
- Konva-based canvas for drawing pattern boxes
- Interactive UI for managing pattern parts
- Form submission with validation

#### Pattern Matches View
- `app/views/size_figures/pattern_matches.html.erb`
- Displays query figure and pattern part details
- Shows matched figures sorted by similarity

### Python Service Endpoints

#### POST `/pattern_match`
**Purpose**: Match pattern parts from query image against target images
**Request**:
```json
{
  "query_image": "/path/to/query.jpg",
  "pattern_boxes": [[x1, y1, x2, y2], ...],
  "target_images": ["/path/to/target1.jpg", ...],
  "feature_type": "texture"
}
```
**Response**:
```json
{
  "success": true,
  "n_query_patterns": 3,
  "n_matches": 12,
  "matches": [
    {
      "query_box": [50, 30, 150, 130],
      "target_box": [120, 45, 220, 145],
      "similarity": 0.85,
      "target_image": "/path/to/target1.jpg"
    }
  ]
}
```

**Feature Types:**
- **Texture**: SIFT descriptors + template matching (threshold: 0.6)
- **Color**: LAB histogram correlation (threshold: 0.7)
- **Edge**: Canny edge detection + HOG-like features (threshold: 0.6)

### Configuration

**Matching Thresholds** (in `torch_service.py`):
```python
# Template matching (texture/edge)
if max_val > 0.6:  # Increase for stricter matching

# Histogram correlation (color)
if similarity > 0.7:  # Increase for stricter matching
```

**Best Practices:**
- Pattern box size: < 200x200 pixels
- Pattern parts per figure: 3-5 recommended
- Use color feature type for faster matching
- Select distinctive, unique patterns
