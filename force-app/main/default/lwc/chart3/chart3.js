import { api, LightningElement, track, wire } from "lwc";
import chartJs from "@salesforce/resourceUrl/ChartJs";
import { loadScript } from "lightning/platformResourceLoader";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
export default class Chart3 extends LightningElement {

    @api loaderVariant = 'base';
    @track chartConfig;
    @api chartLabels;
    @api chartLabel1;
    @api chartData1=[];
    @api chartData2=[];
    @api chartData3=[];
    @api chartType;
    @api valueLabel1;
    @api valueLabel2;
    @api valueLabel3;

    @track isChartJsInitialized;
    renderedCallback() {
        if (this.isChartJsInitialized) {
         return;
        }
        Promise.all([loadScript(this, chartJs)])
         .then(() => {
          this.isChartJsInitialized = true;
          const ctx = this.template.querySelector('canvas.chart').getContext('2d');
            this.chartConfig={
              type: 'bar',
              data: {
                      datasets: [
                        {
                          label: 'Sponsor Credit',
                          data: this.chartData1,
                          yAxisID: "y-axis-1",
                          backgroundColor:'rgba(0,153,51,0.8)'
                          },
                          {
                            label: 'Soft Credit',
                            data: this.chartData3,
                            yAxisID: "y-axis-1",
                            backgroundColor:'rgba(255,153,51,0.8)'
                          },
                          {
                              label: 'Score',
                              data: this.chartData2,
                              backgroundColor:'rgba(0, 0, 0,1)',
                              borderColor:'rgba(255,255,255,0)',
                              yAxisID: "y-axis-2",
                              pointBorderWidth:10,
                              pointRadius:8,
                              pointStyle:'triangle',
                              // Changes this dataset to become a line
                              type: 'line',
                              fill: false
                        }],
                      labels: this.chartLabels
                    },
            options: {
              responsive:true,
              tooltips: {
                mode: 'index',
                intersect: true
              },
      scales: {
          xAxes: [{
            stacked: true,
            ticks: {
              display:true,
              callBack: function (value, index, values) {
                 return value+ "%";
               }
          }
          }],
          yAxes: [{
                  type:'linear',
                  stacked:true,
                  display:true,
                  position: "left",
                  id:"y-axis-1",
                  ticks: {
                    display:true,
                    beginAtZero: true,
                    buildTicks: function(value, index, values) {
                      // alert(value);
                      // alert(index);
                      // alert(values);
                      return '$' + value;
                    }
                  //   callback: function(label,index,labels) {
                  //     alert(label);
                  //     alert(index);
                  //     alert(labels);
                  //     // var ranges = [
                  //     //    { divider: 1000000, suffix: 'M' },
                  //     //    { divider: 1000, suffix: 'K' }
                  //     // ];
                  //     // function formatNumber(n) {
                  //     //    for (var i = 0; i < ranges.length; i++) {
                  //     //       if (n >= ranges[i].divider) {
                  //     //          return (n / ranges[i].divider).toString() + ranges[i].suffix;
                  //     //       }
                  //     //    }
                  //     //    return n;
                  //     // }
                  //     return label+'K';
                  //  }
                  },
                  gridLines: {
                    zeroLineColor: 'rgb(255,255,255)',
                    color: 'rgb(255,255,255)'
                  }
            },
                {
                  type:"linear",
                  display:true,
                  position: "right",
                  id:"y-axis-2",
                  ticks: {
                    beginAtZero: true,
                }
            }
        ]
      }
  }
            };          
          this.chart = new window.Chart(ctx, JSON.parse(JSON.stringify(this.chartConfig)));
          this.chart.canvas.parentNode.style.height = '53%';
          this.chart.canvas.parentNode.style.width = '53%';
         })
         .catch(error => {
          this.dispatchEvent(
           new ShowToastEvent({
            title: 'Error loading ChartJS',
            message: error.message,
            variant: 'error',
           })
          );
         });
       }
}