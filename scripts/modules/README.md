# Torch Service Modules

This directory contains the modular refactoring of the torch service.

## Architecture

The service is organized into the following modules:

### Core Modules

- **models.py** - Central registry for all loaded PyTorch models
  - `ModelRegistry` class manages model initialization and access
  - Loads detection model, SAM, arrow model, and skeleton model
  - Provides property accessors for all models and labels

- **features.py** - Feature extraction utilities
  - `extract_local_features()` - SIFT and ORB feature extraction
  - `extract_pattern_feature()` - Texture, color, and edge features
  - Helper functions for feature filtering and preprocessing

- **analysis.py** - ML analysis functions
  - `analyze_file()` - Object detection analysis
  - `analyze_arrow()` - Arrow orientation prediction
  - `analyze_skeleton()` - Skeleton classification
  - `extract_object_features()` - BOVW or backbone feature extraction

- **sam.py** - Segment Anything Model (SAM) operations
  - `segment_image()` - Image segmentation based on user points
  - `save_masks_as_images()` - Save segmentation masks to files

- **bovw.py** - Bag of Visual Words training and computation
  - `train_visual_vocabulary()` - Train K-Means vocabulary
  - `compute_bovw_features()` - Compute TF-IDF weighted BOVW features
  - `compute_similarity_matrix()` - Compute image similarity matrix

- **pattern_match.py** - Pattern matching across images
  - `match_pattern_parts()` - Match pattern regions across images
  - Support for texture, color, and edge feature matching

- **routes.py** - Bottle route handlers
  - HTTP endpoint handlers that call the appropriate module functions
  - Error handling and response formatting

### Entry Point

- **torch_service.py** (parent directory) - Main application entry point
  - Creates Bottle app
  - Initializes models
  - Defines routes
  - Handles production vs development mode

## Module Dependencies

```
torch_service.py
    └── modules/
        ├── models.py (no dependencies)
        ├── features.py (no dependencies)
        ├── analysis.py → models, features, transforms
        ├── sam.py → models
        ├── bovw.py → features
        ├── pattern_match.py → features
        └── routes.py → analysis, bovw, sam, pattern_match
```

## Function Length Guidelines

All functions are kept under 30 lines by:
- Extracting helper functions for complex operations
- Using private helper functions for specific tasks
- Separating concerns between modules

## Adding New Features

1. **New analysis type**: Add function to `analysis.py`
2. **New feature extraction**: Add function to `features.py`
3. **New ML model**: Add to `ModelRegistry` in `models.py`
4. **New endpoint**: Add handler to `routes.py`, register in `torch_service.py`
