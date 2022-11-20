from django.core.management.base import BaseCommand, CommandError
from graves.models import *
import csv
from django.db import transaction
import os
from scipy.spatial import distance
import numpy as np
import cv2
import math

class Command(BaseCommand):
    help = 'build arrow angles'

    def handle(self, *args, **options):
        with transaction.atomic():
            for arrow in Arrow.objects.prefetch_related('figure__page').all():
                self.handle_arrow(arrow)

    def handle_arrow(self, arrow):
        figure = arrow.figure
        image = figure.page.image
        image = np.asarray(bytearray(image), dtype='uint8')
        image = cv2.imdecode(image, cv2.IMREAD_COLOR)

        arrow_image = image[int(figure.y1):int(figure.y2), int(figure.x1):int(figure.x2)]
        image = cv2.cvtColor(arrow_image, cv2.COLOR_BGR2GRAY)
        image = 255 - image

        _, image = cv2.threshold(image, 40, 255, cv2.THRESH_BINARY)

        contours, _ = cv2.findContours(image, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        # determine correct contour
        if len(contours) > 0:
            moments = cv2.moments(contours[0])
            cx = int(moments['m10'] / (moments['m00'] + 1e-5))
            cy = int(moments['m01'] / (moments['m00'] + 1e-5))

            [vx,vy,x,y] = cv2.fitLine(contours[0], cv2.DIST_L2,0,0.01,0.01)
            y_axis = np.array([0, 1])
            center_line = np.array([vx, vy])
            dot_product = np.dot(y_axis, center_line)
            angle_2_y = np.arccos(dot_product)

            rect = cv2.minAreaRect(contours[0])
            box = cv2.boxPoints(rect)
            box = np.int0(box)

            degree_angle = math.degrees(angle_2_y)

            print(cx)
            print(cy)
