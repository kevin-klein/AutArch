from django.db import models
import numpy as np
# Create your models here.

class Publication(models.Model):
    pdf = models.BinaryField()
    author = models.CharField(max_length=512)
    title = models.CharField(max_length=512)

class Site(models.Model):
    lat = models.IntegerField()
    lon = models.IntegerField()
    location = models.CharField(max_length=64)
    publication = models.ForeignKey(Publication, on_delete=models.CASCADE)

class Page(models.Model):
    image = models.BinaryField()
    number = models.IntegerField()
    publication = models.ForeignKey(Publication, on_delete=models.CASCADE)

class Figure(models.Model):
    page = models.ForeignKey(Page, on_delete=models.CASCADE)
    x1 = models.FloatField()
    x2 = models.FloatField()
    y1 = models.FloatField()
    y2 = models.FloatField()
    type_name = models.CharField(max_length=64)
    tags = models.CharField(max_length=512)

    @property
    def pos(self):
        return np.array([self.x1, self.y1, self.x2, self.y2])

    @property
    def center(self):
        return np.array([(self.x1 + self.x2) / 2.0, (self.y1 + self.y2) / 2.0])

    def collides(self, other_figure):
        return (
            self.x1 < other_figure.x1 + other_figure.width and
            self.x1 + self.width > other_figure.height and
            self.y1 < other_figure.y1 + other_figure.height and
            self.y1 + self.height > other_figure.y1
        )

    @property
    def width(self):
        return self.x2 - self.x1

    @property
    def height(self):
        return self.y2 - self.y1

class Grave(models.Model):
    site = models.ForeignKey(Site, null=True, on_delete=models.CASCADE)
    figure = models.ForeignKey(Figure, on_delete=models.CASCADE)

class Skeleton(models.Model):
    grave = models.ForeignKey(Grave, on_delete=models.CASCADE)
    figure = models.ForeignKey(Figure, on_delete=models.CASCADE)
    angle = models.FloatField()

class Skull(models.Model):
    skeleton = models.ForeignKey(Skeleton, on_delete=models.CASCADE)
    figure = models.ForeignKey(Figure, on_delete=models.CASCADE)

class Scale(models.Model):
    figure = models.ForeignKey(Figure, on_delete=models.CASCADE)
    meter_ratio = models.FloatField()
    grave = models.ForeignKey(Grave, on_delete=models.CASCADE)

class Arrow(models.Model):
    grave = models.ForeignKey(Grave, on_delete=models.CASCADE)
    figure = models.ForeignKey(Figure, on_delete=models.CASCADE)
    angle = models.FloatField()

class GraveCrossSection(models.Model):
    grave = models.OneToOneField(Grave, on_delete=models.CASCADE)
    figure = models.ForeignKey(Figure, on_delete=models.CASCADE)

class Good(models.Model):
    type = models.CharField(max_length=128)
    figure = models.ForeignKey(Figure, on_delete=models.CASCADE)
    grave = models.ForeignKey(Grave, on_delete=models.CASCADE)
