#!/usr/bin/env -S node --import tsx
//MISE description="DevContainer Features 清理任务"
//USAGE flag "-y --yes" help="默认选中确认执行，并自动保存日志"
/**
 * DevContainer Features 清理任务
 *
 * cleanup.ts 保留清理任务自身的预览与执行逻辑；
 * utils.ts 只保留 test / cleanup 共用的运行时配置。
 */

import type { WorkflowCommandTaskIO } from 'clack-kit'
import { defineStep, defineSteps, defineWorkflow } from 'clack-kit'
import {
  createTaskLogConfig,
  createTaskRunOptions,
  createTaskWorkflowKit,
  isNonInteractiveRun,
} from './utils'

const RETAINED_TEST_ARTIFACT_PATTERN = 'vsc-.*-features(-uid)?'
const CLEANUP_CONTAINER_QUERY = `docker ps -a --format "{{.ID}}\\t{{.Image}}" | grep -E "${RETAINED_TEST_ARTIFACT_PATTERN}" | awk '{print $1}'`
const CLEANUP_IMAGE_QUERY = `docker images --format "{{.ID}}\\t{{.Repository}}" | grep -E "${RETAINED_TEST_ARTIFACT_PATTERN}" | awk '{print $1}'`
const CLEANUP_ALL_IMAGES_QUERY = 'docker images -aq'

function buildCleanupPreview(): string {
  return [
    CLEANUP_CONTAINER_QUERY,
    'echo "<containerIds>" | xargs docker rm -f',
    '',
    CLEANUP_IMAGE_QUERY,
    'echo "<imageIds>" | xargs docker rmi -f',
    '',
    `${CLEANUP_ALL_IMAGES_QUERY}  # 可选：清理全部镜像`,
    'echo "<allImageIds>" | xargs docker rmi -f',
    '',
    'docker builder prune -af',
  ].join('\n')
}

async function removeArtifacts(
  io: WorkflowCommandTaskIO,
  options: {
    query: string
    emptyMessage: string
    removingMessage: string
    successMessage: string
    removeCommand: (ids: string) => string
  },
): Promise<void> {
  const result = await io.exec(options.query)
  const ids = (result.stdout ?? '').trim()

  if (!ids) {
    io.log('info', options.emptyMessage)
    return
  }

  io.log('step', options.removingMessage)
  await io.exec(options.removeCommand(ids))
  io.log('success', options.successMessage)
}

async function runCleanup(io: WorkflowCommandTaskIO, cleanupAllImages: boolean): Promise<void> {
  io.log('step', '正在查找测试容器...')
  await removeArtifacts(io, {
    query: CLEANUP_CONTAINER_QUERY,
    emptyMessage: '没有找到 vsc-*-features 测试容器',
    removingMessage: '正在删除容器...',
    successMessage: '✓ 容器清理完成',
    removeCommand: ids => `echo "${ids}" | xargs docker rm -f`,
  })

  io.log('step', '正在查找测试镜像...')
  await removeArtifacts(io, {
    query: CLEANUP_IMAGE_QUERY,
    emptyMessage: '没有找到 vsc-*-features 测试镜像',
    removingMessage: '正在删除镜像...',
    successMessage: '✓ 镜像清理完成',
    removeCommand: ids => `echo "${ids}" | xargs docker rmi -f`,
  })

  if (cleanupAllImages) {
    io.log('step', '正在查找全部 Docker 镜像...')
    await removeArtifacts(io, {
      query: CLEANUP_ALL_IMAGES_QUERY,
      emptyMessage: '没有找到可清理的 Docker 镜像',
      removingMessage: '正在删除全部 Docker 镜像...',
      successMessage: '✓ 全部 Docker 镜像清理完成',
      removeCommand: ids => `echo "${ids}" | xargs docker rmi -f`,
    })
  }

  io.log('step', '正在清理 Docker 构建缓存...')
  await io.exec('docker builder prune -af')
  io.log('success', '✓ 构建缓存清理完成')
  io.log('success', '🎉 所有清理操作完成！')
}

const isNonInteractive = isNonInteractiveRun(process.env.usage_yes === 'true')

const workflow = defineWorkflow({
  id: 'devcontainer-feature-cleanup',
  intro: '🧹 DevContainer Features 清理工具',
  log: createTaskLogConfig(isNonInteractive),
  steps: defineSteps([
    defineStep.note({
      id: 'cleanupPreview',
      title: '待执行命令',
      message: buildCleanupPreview(),
    }),
    defineStep.confirm({
      id: 'cleanupAllImages',
      message: '额外清理全部 Docker 镜像？（危险操作）',
      defaultValue: false,
    }),
    defineStep.command({
      id: 'doCleanup',
      title: '清理测试容器和镜像',
      confirm: !isNonInteractive ? { message: '确认执行清理操作？', defaultValue: true } : undefined,
      run: (ctx, io) => runCleanup(io, ctx.values.cleanupAllImages === true),
    }),
  ]),
})

await createTaskWorkflowKit().runSafely(workflow, createTaskRunOptions({
  entry: 'mise-tasks/cleanup.ts',
  isNonInteractive,
}))
