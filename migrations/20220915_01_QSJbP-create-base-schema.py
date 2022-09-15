"""
create base schema
"""

from yoyo import step

__depends__ = {}

steps = [
    step(
        """CREATE TABLE publications (
            id bigserial PRIMARY KEY,
            file varchar(256) NOT NULL UNIQUE,
            author varchar(256),
            title varchar(256)
        )
        """,
        "DROP TABLE publications"
    ),
    step(
        '''
        CREATE TABLE pages (
            id bigserial PRIMARY KEY,
            number numeric NOT NULL CHECK (number > 0),
            image_file varchar(256) NOT NULL,
            publication_id integer NOT NULL REFERENCES publications ON DELETE CASCADE
        )
        ''',
        'DROP TABLE pages'
    ),
    step(
        '''
        CREATE TABLE images (
            id bigserial PRIMARY KEY,
            page_id integer NOT NULL REFERENCES pages ON DELETE CASCADE,
            image_file varchar(256) NOT NULL
        )
        ''',
        'DROP TABLE images'
    ),
    step(
        '''
        create table items (
            id bigserial PRIMARY KEY,
            name varchar(256)
        )
        ''',
        'drop table items'
    ),
    step(
        '''
        CREATE TABLE shapes (
            id bigserial primary key,
            image_id integer NOT NULL REFERENCES images ON DELETE CASCADE,
            contour jsonb NOT NULL,
            item_id integer REFERENCES items ON DELETE CASCADE
        )
        ''',
        'DROP TABLE shapes'
    ),
]
