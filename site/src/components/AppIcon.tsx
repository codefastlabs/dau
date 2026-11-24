/** The Dấu icon (docs/Brand.md): "ấ" in Paper on Ink, the acute in Vermilion. */
export function AppIcon({ size, outlined = false }: { size: number; outlined?: boolean }) {
  return (
    <svg width={size} height={size} viewBox="0 0 100 100" aria-hidden="true" className="flex-none">
      <rect x="0" y="0" width="100" height="100" rx="22.4" className="fill-ink" />
      {outlined ? (
        <rect
          x="0.75"
          y="0.75"
          width="98.5"
          height="98.5"
          rx="21.7"
          fill="none"
          strokeWidth="1.5"
          className="stroke-paper/35"
        />
      ) : null}
      <text
        x="48"
        y="80"
        textAnchor="middle"
        fontWeight="700"
        fontSize="64"
        className="fill-paper font-sans"
      >
        a
      </text>
      <path
        d="M34 35 L47 25 L60 35"
        fill="none"
        strokeWidth="7"
        strokeLinecap="round"
        strokeLinejoin="round"
        className="stroke-paper"
      />
      <path
        d="M63 24 L73 13"
        fill="none"
        strokeWidth="7.5"
        strokeLinecap="round"
        className="stroke-vermilion"
      />
    </svg>
  );
}
