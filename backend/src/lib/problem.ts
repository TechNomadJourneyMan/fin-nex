// RFC 9457 Problem Details helpers.

export interface ProblemDetails {
  type: string;
  title: string;
  status: number;
  code: string;
  detail: string;
  instance?: string;
  trace_id?: string;
  errors?: Array<{ field: string; code: string; message: string }>;
  retry_after_seconds?: number;
}

export class ApiError extends Error {
  public readonly status: number;
  public readonly code: string;
  public readonly detail: string;
  public readonly errors?: Array<{ field: string; code: string; message: string }>;

  constructor(
    status: number,
    code: string,
    detail: string,
    errors?: Array<{ field: string; code: string; message: string }>,
  ) {
    super(detail);
    this.status = status;
    this.code = code;
    this.detail = detail;
    this.errors = errors;
  }
}

const BASE = 'https://api.finnex.kz/problems';

/** Builds an RFC 9457 problem document. */
export function toProblem(
  err: ApiError,
  opts: { instance?: string; traceId?: string },
): ProblemDetails {
  return {
    type: `${BASE}/${err.code.toLowerCase()}`,
    title: titleFor(err.code),
    status: err.status,
    code: err.code,
    detail: err.detail,
    instance: opts.instance,
    trace_id: opts.traceId,
    errors: err.errors,
  };
}

function titleFor(code: string): string {
  return code
    .toLowerCase()
    .split('_')
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join(' ');
}
