import { useEffect, useState } from 'react';
import { ActivityIndicator, Pressable, StyleSheet, Text, View } from 'react-native';
import { Stack } from 'expo-router';
import { HealthResponse } from '@starter/shared';
import { API_URL, apiGet } from '@/lib/api';

type State =
  | { kind: 'loading' }
  | { kind: 'ok'; health: HealthResponse }
  | { kind: 'error'; message: string };

async function fetchHealth(): Promise<State> {
  try {
    return { kind: 'ok', health: await apiGet('/health', HealthResponse) };
  } catch (e) {
    return { kind: 'error', message: e instanceof Error ? e.message : String(e) };
  }
}

export default function Index() {
  const [state, setState] = useState<State>({ kind: 'loading' });

  useEffect(() => {
    let active = true;
    fetchHealth().then((next) => active && setState(next));
    return () => {
      active = false;
    };
  }, []);

  const recheck = () => {
    setState({ kind: 'loading' });
    fetchHealth().then(setState);
  };

  return (
    <View style={styles.container}>
      <Stack.Screen options={{ title: 'Health check' }} />
      {state.kind === 'loading' && <ActivityIndicator />}
      {state.kind === 'ok' && (
        <>
          <Text style={styles.big}>API ✓  DB ✓</Text>
          <Text>DB time: {state.health.db.serverTime}</Text>
          <Text>Users: {state.health.db.userCount}</Text>
        </>
      )}
      {state.kind === 'error' && (
        <>
          <Text style={styles.big}>Cannot reach the API</Text>
          <Text>{state.message}</Text>
        </>
      )}
      <Text style={styles.muted}>{API_URL}</Text>
      <Pressable style={styles.button} onPress={recheck}>
        <Text style={styles.buttonText}>Check again</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center', gap: 8, padding: 24 },
  big: { fontSize: 22, fontWeight: '600' },
  muted: { color: '#888', marginTop: 16 },
  button: { backgroundColor: '#208AEF', paddingHorizontal: 20, paddingVertical: 12, borderRadius: 8, marginTop: 8 },
  buttonText: { color: 'white', fontWeight: '600' },
});
