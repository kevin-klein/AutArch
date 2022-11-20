from django.core.management.base import BaseCommand, CommandError
from graves.models import Figure, Grave, Publication, Site, Skeleton, Skull, Arrow, Scale, Page
import csv
from django.db import transaction
import os
from gluoncv import data
import cv2

def read_publication_name(file_name):
    return '-'.join(file_name.split('-')[:-1])

def get_page_numer(file_name):
    return int(file_name.split('-')[-1].replace('.jpg', ''))

def get_pdf(name):
    pdf_file = '{}.pdf'.format(name)
    pdf_path = os.path.join('..', 'pdfs', pdf_file)
    with open(pdf_path, 'rb') as f:
        return f.read()

class Command(BaseCommand):
    help = 'imports graves csv'

    def __init__(self):
        super().__init__()
        self.publications = {}

    def add_arguments(self, parser):
        parser.add_argument('csv', nargs=1, type=str)

    def get_or_create_publication(self, name):
        publication = self.publications.get(name)
        if publication is None:
            pdf = get_pdf(name)
            publication = Publication.objects.create(title=name, pdf=pdf)
            self.publications[name] = publication
        return publication

    def get_or_create_page(self, publication, file_name):
        page_number = get_page_numer(file_name)
        page = publication.page_set.filter(number=page_number).first()
        if page is None:
            image = data.transforms.presets.ssd.load_test(os.path.join('..', 'pdfs', 'page_images', file_name), short=512)

            page = publication.page_set.create(image=cv2.imencode('.jpg', image[1])[1], number=page_number)
        return page

    def handle(self, *args, **options):
        with open(options['csv'][0]) as f:
            reader = csv.DictReader(f, delimiter=',', quotechar='"')
            with transaction.atomic():
                for row in reader:
                    name = read_publication_name(row['file'])

                    publication = self.get_or_create_publication(name)

                    page = self.get_or_create_page(publication, row['file'])

                    page.figure_set.create(
                        x1=row['x1'],
                        x2=row['x2'],
                        y1=row['y1'],
                        y2=row['y2'],
                        type_name=row['class'],
                        tags=[]
                    )

        self.stdout.write('imported data {} graves'.format(Figure.objects.count()))
        #
        # for poll_id in options['poll_ids']:
        #     try:
        #         poll = Poll.objects.get(pk=poll_id)
        #     except Poll.DoesNotExist:
        #         raise CommandError('Poll "%s" does not exist' % poll_id)
        #
        #     poll.opened = False
        #     poll.save()
        #
        #     self.stdout.write(self.style.SUCCESS('Successfully closed poll "%s"' % poll_id))
