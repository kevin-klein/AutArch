from django.core.management.base import BaseCommand, CommandError
from graves.models import *
import csv
from django.db import transaction
import os
from scipy.spatial import distance
import numpy as np

def find_closest_item(grave_figure, figures):
    if len(figures) == 0:
        return None

    distances = [distance.euclidean(grave_figure.center, figure.center) for figure in figures]
    return figures[np.argmin(distances)]

def get_pdf(name):
    pdf_file = '{}.pdf'.format(name)
    pdf_path = os.path.join('..', 'pdfs', pdf_file)
    with open(pdf_path, 'rb') as f:
        return f.read()

class Command(BaseCommand):
    help = 'imports graves csv'

    def convert_figures(self, figures):
        result = {}
        for figure in figures:
            if figure.type_name in ('arrow_up', 'arrow_left', 'arrow_right'):
                arr = result.get('arrow', [])
                arr.append(figure)
                result['arrow'] = arr
            else:
                arr = result.get(figure.type_name, [])
                arr.append(figure)
                result[figure.type_name] = arr
        return result

    def handle(self, *args, **options):
        with transaction.atomic():
            for page in Page.objects.prefetch_related('figure_set').all():
                figures = self.convert_figures(page.figure_set.all())
                grave_figures = figures.get('grave', [])
                for grave in grave_figures:
                    self.handle_grave(grave, figures)

    def handle_grave(self, grave_figure, figures):
        all_figures = sum(figures.values(), [])
        non_grave_figures = [figure for figure in all_figures if figure.type_name != 'grave']

        inside_grave = [figure for figure in non_grave_figures if grave_figure.collides(figure)]

        grave = Grave.objects.create(figure=grave_figure)

        closest_scale = find_closest_item(grave_figure, figures.get('scale', []))
        if closest_scale is not None:
            Scale.objects.create(grave=grave, figure=closest_scale, meter_ratio=-1)

        closest_arrow = find_closest_item(grave_figure, figures.get('arrow', []))
        if closest_arrow is not None:
            Arrow.objects.create(grave=grave, figure=closest_arrow, angle=-1)

        skeletons = [figure for figure in inside_grave if figure.type_name in ('skeleton_left_side', 'skeleton_right_side')]
        for skeleton in skeletons:
            self.handle_skeleton(skeleton, grave, figures)

        goods = [figure for figure in inside_grave if figure.type_name == 'goods']
        for good in goods:
            Good.objects.create(
                figure=good,
                grave=grave
            )

        cross_section_figure = find_closest_item(grave_figure, figures.get('grave_cross_section', []))
        if cross_section_figure is not None:
            GraveCrossSection.objects.create(
                grave=grave,
                figure=cross_section_figure
            )

    def handle_skeleton(self, skeleton_figure, grave, figures):
        skeleton = Skeleton.objects.create(
            grave=grave,
            figure=skeleton_figure,
            angle=-1
        )

        skulls = figures.get('skull', [])
        skulls = [skull for skull in skulls if skull.collides(skeleton_figure)]
        skull_figure = find_closest_item(grave.figure, skulls)
        if skull_figure is not None:
            Skull.objects.create(
                skeleton=skeleton,
                figure=skull_figure
            )
