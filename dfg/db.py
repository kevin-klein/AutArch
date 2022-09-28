import psycopg2.extras
import io
import numpy as np

def image_to_bytes(image):
    data = io.BytesIO()
    np.save(data, image, allow_pickle=False, fix_imports=False)
    return data.getvalue()

def persist_images(db, images):
    data = [image_to_bytes(image) for image in images]

    query = 'INSERT INTO publications (file) VALUES %s RETURNING *'
    psycopg2.extras.execute_values(
        db, query, data, template=None, page_size=64
    )
    return query.fetchall()

def persist_publications(db, publications):
    for publication in publications:
        db.execute('INSERT INTO publications VALUES (%%s) RETURN *', [publication.get('file')])
        id = db.fetchone()[0]

        persist_pages(db, id, publication.get('pages'))

def persist_pages(db, pdf, image_paths):
    image_paths = enumerate(image_paths)
    data = map(lambda (idx, path): (path, idx, pdf['id']), pdfs)

    query = 'INSERT INTO pages (image_file, number, publication_id) VALUES %s RETURNING *'
    psycopg2.extras.execute_values(
        db, query, data, template=None, page_size=64
    )

    return query.fetchall()

def save_images(db, page, images):
    data = map(lambda image: (image, page['id']), images)

    query = 'INSERT INTO pages (image_file, page_id) VALUES %s RETURNING *'
    psycopg2.extras.execute_values(
        db, query, data, template=None, page_size=64
    )

    return query.fetchall()
