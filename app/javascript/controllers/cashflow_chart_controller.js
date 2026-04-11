import { Controller } from "@hotwired/stimulus"
import { Chart, LineElement, PointElement, LinearScale, CategoryScale, Legend, Tooltip, Filler } from "chart.js"

Chart.register(LineElement, PointElement, LinearScale, CategoryScale, Legend, Tooltip, Filler)

export default class extends Controller {
  static values = {
    labels: Array,
    income: Array,
    expenses: Array
  }

  connect() {
    this.chart = new Chart(this.element, {
      type: "line",
      data: {
        labels: this.labelsValue,
        datasets: [
          {
            label: "Cumulative Income",
            data: this.incomeValue,
            borderColor: "#16a34a",
            backgroundColor: "rgba(22, 163, 74, 0.08)",
            fill: true,
            tension: 0.3,
            pointRadius: 3,
            borderWidth: 2
          },
          {
            label: "Cumulative Expenses",
            data: this.expensesValue,
            borderColor: "#dc2626",
            backgroundColor: "rgba(220, 38, 38, 0.08)",
            fill: true,
            tension: 0.3,
            pointRadius: 3,
            borderWidth: 2
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: { mode: "index", intersect: false },
        plugins: {
          legend: {
            position: "top",
            labels: { font: { size: 11 }, boxWidth: 12, padding: 12 }
          },
          tooltip: {
            callbacks: {
              label: (ctx) => ` ${ctx.dataset.label}: ${ctx.parsed.y.toLocaleString("en", { minimumFractionDigits: 2 })}`
            }
          }
        },
        scales: {
          x: {
            ticks: { font: { size: 11 } },
            grid: { color: "rgba(0,0,0,0.04)" }
          },
          y: {
            ticks: {
              font: { size: 11 },
              callback: (v) => v.toLocaleString("en", { minimumFractionDigits: 0 })
            },
            grid: { color: "rgba(0,0,0,0.04)" }
          }
        }
      }
    })
  }

  disconnect() {
    this.chart?.destroy()
  }
}
