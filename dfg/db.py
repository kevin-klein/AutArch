import psycopg2.extras

def save_publications(db, pdfs):
    data = map(lambda file: (file, ), pdfs)

    query = 'INSERT INTO publications (file) VALUES %s RETURNING *'
    psycopg2.extras.execute_values(
        db, query, data, template=None, page_size=64
    )

    return query.fetchall()

def save_pages(db, pdf, image_paths):
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
