/**
 * Trackt die Online-Spieleranzahl über die letzten Stunden
 * für die Sparkline-Anzeige im Banner.
 */

const HISTORY_MAX = 24; // Max Datenpunkte (= letzte 24 Intervalle)
const history: number[] = [];

/**
 * Neuen Datenpunkt hinzufügen
 */
export function recordOnlineCount(count: number): void {
  history.push(count);
  if (history.length > HISTORY_MAX) {
    history.shift();
  }
}

/**
 * Aktuelle History abrufen (0 = ältester, n = neuester)
 */
export function getOnlineHistory(): number[] {
  return [...history];
}

/**
 * Max-Wert in der History
 */
export function getHistoryMax(): number {
  if (history.length === 0) return 1;
  return Math.max(...history, 1);
}
