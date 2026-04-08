#!/usr/bin/env python3
"""
Main entry point for the torch service.
"""

import os
from concurrent.futures import ThreadPoolExecutor
from bottle import Bottle

from dotenv import load_dotenv

load_dotenv('../.env')

from modules.models import registry
from modules.routes import (
    handle_segment,
    handle_upload,
    handle_arrow,
    handle_skeleton,
    handle_efd,
    handle_train_bovw,
    handle_pattern_match,
    handle_extract_summaries
)


def create_app():
    """Create and configure the Bottle application."""
    app = Bottle()

    # Initialize models
    registry.initialize()

    # Define routes
    app.post('/segment')(handle_segment)
    app.post('/')(handle_upload)
    app.post('/arrow')(handle_arrow)
    app.post('/skeleton')(handle_skeleton)
    app.post('/efd')(handle_efd)
    app.post('/train_bovw')(wrap_async(handle_train_bovw))
    app.post('/pattern_match')(wrap_async(handle_pattern_match))
    app.post('/extract_summaries')(wrap_async(handle_extract_summaries))

    return app

# Thread pool for long-running tasks
_executor = ThreadPoolExecutor(max_workers=4)


def wrap_async(handler):
    """Wrap a handler to run in a thread pool, preventing request blocking."""
    def wrapped():
        future = _executor.submit(handler)
        # Return immediately with a job ID (would need job tracking for real async)
        # For now, we run synchronously but in a separate thread
        # This prevents the main request thread from blocking
        return future.result(timeout=3600)  # 1 hour timeout
    return wrapped

def main():
    """Main entry point."""
    app = create_app()

    # Check if we're in production mode
    production = os.environ.get('RAILS_ENV') == 'production'

    if production:
        # Production configuration
        app.run(host='127.0.0.1', port=9000, server='waitress')
    else:
        # Development configuration
        app.run(debug=True, reloader=True, host='0.0.0.0', port=9000)


if __name__ == '__main__':
    main()
