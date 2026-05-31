// ID helpers — ULID with type prefix.
import { ulid } from 'ulid';

export type IdPrefix =
  | 'usr'
  | 'acc'
  | 'tx'
  | 'cat'
  | 'bud'
  | 'tag'
  | 'ntf'
  | 'ins'
  | 'dev'
  | 'ses'
  | 'sub'
  | 'job'
  | 'rft'
  | 'otp'
  | 'evt'
  | 'aud'
  | 'ref'
  | 'pay'
  | 'flg'
  | 'fx';

/** Creates a prefixed ULID like `tx_01HXY...`. */
export function newId(prefix: IdPrefix): string {
  return `${prefix}_${ulid()}`;
}

/** Strips the prefix, returning the ULID portion. */
export function stripPrefix(id: string): string {
  const idx = id.indexOf('_');
  return idx === -1 ? id : id.slice(idx + 1);
}
