/* The form archetype — one solution covering 12 screens.
 * Label above field, error stated in words and tied to the field, one bottom-anchored
 * primary action. The error state is shown here deliberately: it is the state the current
 * app handles worst. */

import { statusBar, appbar } from '../components.js';
import { icon } from '../icons.js';

export const meta = { id: 'login', title: 'Log in', group: 'Entry', tag: 'form' };

export function render() {
  return `<div class="screen">
    ${statusBar()}
    ${appbar({ title: 'Log in', hero: true, back: true })}

    <div class="content">
      <p class="t-body c-secondary" style="margin:0">
        Use the phone number or email on your Vinkol account.
      </p>

      <div class="field">
        <label class="field__label" for="lg-id">Phone number or email</label>
        <input class="field__input" id="lg-id" value="emeka@example.com" />
      </div>

      <div class="field field--error">
        <label class="field__label" for="lg-pw">Password</label>
        <input class="field__input" id="lg-pw" type="password" value="hunter22"
               aria-describedby="lg-pw-err" />
        <div class="field__error" id="lg-pw-err">
          ${icon('alert', 16)}
          <span>That password doesn't match this account. Try again or reset it.</span>
        </div>
      </div>

      <div class="mt-md" style="display:flex;justify-content:flex-end">
        <button class="btn btn--ghost" style="padding:0">Reset password</button>
      </div>
    </div>

    <div class="action-bar">
      <button class="btn btn--primary btn--block">Log in</button>
      <div class="center mt-lg t-body-s c-secondary">
        New to Vinkol? <b style="color:var(--text-brand)">Create an account</b>
      </div>
    </div>
  </div>`;
}
