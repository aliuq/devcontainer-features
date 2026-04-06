import { createWorkflowKit, type WorkflowLogOptions, type WorkflowRunOptions } from 'clack-kit'
import { resolve } from 'node:path'
import { fileURLToPath } from 'node:url'

const __dirname = fileURLToPath(new URL('.', import.meta.url))

export const ROOT = resolve(__dirname, '..')

export function createTaskWorkflowKit() {
  return createWorkflowKit({
    asciiArt: false,
    history: true,
    logs: true,
    cwd: ROOT,
  })
}

export function isNonInteractiveRun(yes: boolean, env: NodeJS.ProcessEnv = process.env): boolean {
  return yes || env.CI === '1' || env.CI === 'true'
}

export function createTaskLogConfig(isNonInteractive: boolean): WorkflowLogOptions {
  return {
    completion: {
      mode: isNonInteractive ? 'save' : 'confirm',
    },
  }
}

export function createTaskRunOptions<TValues extends Record<string, unknown>>(options: {
  entry: string
  initialValues?: Partial<TValues>
  isNonInteractive: boolean
}): WorkflowRunOptions<TValues> {
  return {
    initialValues: options.initialValues,
    history: {
      reuse: options.isNonInteractive ? 'off' : 'ask',
      saveSnapshot: true,
    },
    logs: {
      enabled: true,
    },
    meta: {
      entry: options.entry,
    },
  }
}
