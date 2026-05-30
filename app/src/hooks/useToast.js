import { useState, useRef, useCallback } from "react";
export default function useToast(duration=2400) {
  const [toast, setToast] = useState(null);
  const timerRef = useRef(null);
  const showToast = useCallback((msg) => {
    setToast(msg);
    clearTimeout(timerRef.current);
    timerRef.current = setTimeout(() => setToast(null), duration);
  }, [duration]);
  return { toast, showToast };
}
