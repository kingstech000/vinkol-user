/* The map is the canvas (signature #5). Every control is an e0 hairline surface — no floating
 * shadowed cards. The booking entry is a single compact block, not a form: the user's first
 * job is to say where, and nothing else competes with it. */

import { statusBar, map, pod, lineGlyph } from '../components.js';
import { icon } from '../icons.js';
import { savedPlaces } from '../fixtures.js';

export const meta = { id: 'home', title: 'Home · book', group: 'Core', tag: 'map' };

export function render() {
  const places = savedPlaces
    .map(
      (p) => `<button class="row">
        <span class="row__icon">${icon(p.icon, 18)}</span>
        <span class="row__body">
          <span class="row__title">${p.title}</span>
          <span class="row__meta">${p.meta}</span>
        </span>
        <span class="row__chevron">${icon('chevron', 16)}</span>
      </button>`
    )
    .join('');

  return `<div class="screen">
    ${map({
      route: false,
      pins: [{ x: 30, y: 34, label: 'You' }],
    })}
    ${statusBar()}

    <div class="map__controls" style="top:96px">
      <button class="btn-icon" aria-label="Map layers">${icon('layers', 18)}</button>
      <button class="btn-icon" aria-label="My location">${icon('locate', 18)}</button>
    </div>

    <div style="position:absolute;left:var(--page-margin);right:var(--page-margin);top:56px;z-index:3">
      <div class="surface pad" style="border-radius:var(--radius-md)">
        <div class="t-label-s c-tertiary">Good morning, Emeka</div>
        <div class="t-h2 c-primary mt-xs">Where is it going?</div>

        <button class="hstack gap-md mt-lg" style="width:100%;background:var(--surface-sunken);
                border:0;border-radius:var(--radius-sm);padding:var(--space-md);cursor:pointer;
                text-align:left;min-height:52px">
          ${lineGlyph()}
          <span class="grow">
            <span class="t-body-s c-tertiary" style="display:block">From · Current location</span>
            <span class="t-h4 c-primary" style="display:block">Add a destination</span>
          </span>
          ${icon('search', 18)}
        </button>
      </div>
    </div>

    <div class="sheet" style="max-height:44%">
      <div class="sheet__grip"></div>
      <div class="sheet__body">
        <div class="section__head" style="margin-top:var(--space-xs)">
          <span class="t-label-s c-tertiary">Saved places</span>
          <button class="btn btn--ghost" style="padding:0;min-height:auto">Manage</button>
        </div>
        <div class="rows">${places}</div>
      </div>
    </div>

    ${pod('home')}
  </div>`;
}
