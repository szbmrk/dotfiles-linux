export const READONLY_SHARED_EVENT = "pi-readonly-state";

export type ReadonlyStateListener = (enabled: boolean) => void;

type ReadonlyGlobalState = {
  enabled: boolean;
  listeners: Set<ReadonlyStateListener>;
};

function getSharedState(): ReadonlyGlobalState {
  const key = "__piReadonlySharedState__";
  const root = globalThis as typeof globalThis & {
    [key]?: ReadonlyGlobalState;
  };

  if (!root[key]) {
    root[key] = {
      enabled: false,
      listeners: new Set<ReadonlyStateListener>(),
    };
  }

  return root[key];
}

export function getReadonlyEnabled(): boolean {
  return getSharedState().enabled;
}

export function setReadonlyEnabled(enabled: boolean): void {
  const state = getSharedState();
  state.enabled = enabled;
  for (const listener of state.listeners) {
    listener(enabled);
  }
}

export function subscribeReadonlyState(
  listener: ReadonlyStateListener,
): () => void {
  const state = getSharedState();
  state.listeners.add(listener);
  return () => {
    state.listeners.delete(listener);
  };
}
