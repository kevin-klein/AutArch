import Controller from './application_controller';

import interact from 'interactjs';
console.log(interact);

export default class extends Controller {
  connect() {
    super.connect();
    console.log('Hello, Stimulus!', this.element);
    this.x = 0;
    this.y = 0;
    const $this = this;

    interact('circle').draggable({
      listeners: {
        start (event) {
          let cx = parseInt(event.target.getAttribute('cx'));
          let cy = parseInt(event.target.getAttribute('cy'));

          $this.point = $this.element.createSVGPoint();
          $this.point.x = event.clientX;
          $this.point.y = event.clientY;
          $this.point = $this.point.matrixTransform($this.element.getScreenCTM().inverse());
          $this.x = $this.point.x - cx;
          $this.y = $this.point.y - cy;
        },
        move (event) {
          let cx = parseInt(event.target.getAttribute('cx'));
          let cy = parseInt(event.target.getAttribute('cy'));

          $this.point.x = event.clientX;
          $this.point.y = event.clientY;
          let cursor = $this.point.matrixTransform($this.element.getScreenCTM().inverse());

          cx = cursor.x - $this.x;
          cy = cursor.y - $this.y;

          event.target.setAttribute('cx', cx);
          event.target.setAttribute('cy', cy);

          const rect = document.getElementById(event.target.dataset.rect);
          if(event.target.dataset.one === '1') {
            const x2 = parseInt(rect.dataset.x2);
            const y2 = parseInt(rect.dataset.y2);

            rect.setAttribute('x', cx);
            rect.setAttribute('y', cy);

            rect.setAttribute('width', x2 - cx);
            rect.setAttribute('height', y2 - cy);
          }
          else {
            rect.setAttribute('width', cx - rect.getAttribute('x'));
            rect.setAttribute('height', cy - rect.getAttribute('y'));
            rect.dataset.x2 = cx;
            rect.dataset.y2 = cy;
          }
        },
      },
    });
  }
}
