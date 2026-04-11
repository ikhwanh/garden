import { Controller } from "@hotwired/stimulus"
import { Chart, LineController, LineElement, PointElement, LinearScale, CategoryScale, Legend, Tooltip, Filler } from "chart.js"

Chart.register(LineController, LineElement, PointElement, LinearScale, CategoryScale, Legend, Tooltip, Filler)

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
            borderColor: "#3b82f6",
            backgroundColor: "rgba(59, 130, 246, 0.08)",
            fill: true,
            tension: 0.3,
            pointRadius: 3,
            borderWidth: 2
          },
          {
            label: "Cumulative Expenses",
            data: this.expensesValue,
            borderColor: "#f97316",
            backgroundColor: "rgba(249, 115, 22, 0.08)",
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
              label: (ctx) => ` ${ctx.dataset.label}: Rp ${ctx.parsed.y.toLocaleString("id", { minimumFractionDigits: 0 })}`
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
              callback: (v) => `Rp ${v.toLocaleString("id", { minimumFractionDigits: 0 })}`
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
