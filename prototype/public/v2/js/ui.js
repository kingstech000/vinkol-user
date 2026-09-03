/* Shared across all three v2 directions: status bar, nav scaffold, map art. Directions
 * supply their own classes — nothing here carries a visual opinion. */
export { icon } from '../../js/icons.js';
export { money, taxLabel, taxOn, setMarket, market } from '../../js/market.js';

export function statusBar(cls = '') {
  return `<div class="sb ${cls}">
    <span>9:41</span>
    <span class="sb__r">
      <svg width="17" height="11" viewBox="0 0 17 11" fill="currentColor"><rect y="7" width="3" height="4" rx="1"/>
        <rect x="4.5" y="5" width="3" height="6" rx="1"/><rect x="9" y="2.5" width="3" height="8.5" rx="1"/>
        <rect x="13.5" width="3" height="11" rx="1"/></svg>
      <svg width="16" height="12" viewBox="0 0 16 12" fill="none" stroke="currentColor" stroke-width="1.3">
        <path d="M1 4.5a10 10 0 0 1 14 0M3.5 7.2a6.5 6.5 0 0 1 9 0"/><circle cx="8" cy="10" r="1" fill="currentColor"/></svg>
      <svg width="25" height="12" viewBox="0 0 25 12" fill="none" stroke="currentColor">
        <rect x=".6" y=".6" width="20" height="10.8" rx="3" stroke-width="1.1" opacity=".45"/>
        <rect x="2.3" y="2.3" width="15.5" height="7.4" rx="1.8" fill="currentColor" stroke="none"/>
        <path d="M22.6 4.3v3.4" stroke-width="2" stroke-linecap="round" opacity=".45"/></svg>
    </span>
  </div>`;
}

/** Dark map art. Directions restyle it through CSS custom properties. */
export function mapArt({ road = '#20242a', ground = '#101215', water = '#0d1418', route = '#2e8bef' } = {}) {
  return `<svg viewBox="0 0 390 700" preserveAspectRatio="xMidYMid slice">
    <rect width="390" height="700" fill="${ground}"/>
    <path d="M-20 520 L200 470 L410 500 L410 660 L-20 680Z" fill="${water}"/>
    <g stroke="${road}" fill="none">
      <path d="M-10 120H400" stroke-width="13"/><path d="M-10 300H400" stroke-width="19"/>
      <path d="M-10 450H400" stroke-width="9"/><path d="M70-10V710" stroke-width="15"/>
      <path d="M250-10V710" stroke-width="11"/><path d="M340-10V710" stroke-width="7"/>
      <path d="M-10 210H180L250 150" stroke-width="7"/>
    </g>
    <g fill="${road}" opacity=".5">
      <rect x="95" y="145" width="60" height="40" rx="4"/><rect x="170" y="145" width="55" height="40" rx="4"/>
      <rect x="95" y="330" width="48" height="52" rx="4"/><rect x="160" y="330" width="70" height="52" rx="4"/>
      <rect x="270" y="330" width="52" height="52" rx="4"/><rect x="95" y="230" width="70" height="42" rx="4"/>
    </g>
    <path d="M105 195 C150 200 150 255 200 300 S265 400 300 452" stroke="${route}" stroke-width="5"
      fill="none" stroke-linecap="round"/>
  </svg>`;
}
