import { create } from 'zustand';
import * as R from 'ramda';

export let useFigureStore = create((set) => ({
  grave: {},
  figures: {},
  updateFigure: function(figure) {
    set(R.over(R.lensPath(['figures', figure.id]), item => R.mergeRight(item, figure)));
  },
  setFigures: function(figures) {
    figures = R.reduce((acc, item) => ({...acc, [item.id]: item}), {}, figures);

    set({ figures: figures });
  },
  removeFigure: function(figure) {
    set(R.dissocPath(['figures', figure.id]));
  },
  addFigure: function(figure) {
    set((state) => R.over(R.lensPath(['figures']), figures => R.assoc(figure.id, figure, figures), state));
  },
  increasePopulation: () => set((state) => ({ bears: state.bears + 1 })),
  removeAllBears: () => set({ bears: 0 }),
}));
