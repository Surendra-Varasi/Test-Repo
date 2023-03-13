import { api, LightningElement, track, wire } from "lwc";
import chartJs from "@salesforce/resourceUrl/ChartJs";
import { loadScript } from "lightning/platformResourceLoader";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class Chart extends LightningElement {
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
    @api withOneData=false;
    @api withTwoData=false;
    @api withThreeData=false;

    @track isChartJsInitialized;
    renderedCallback() {
        if (this.isChartJsInitialized) {
         return;
        }
        // load static resources.
        Promise.all([loadScript(this, chartJs)])
         .then(() => {
          //alert("Chart Initialized");
          this.isChartJsInitialized = true;
          const ctx = this.template.querySelector('canvas.chart').getContext('2d');
          if(this.withOneData==true){
            this.chartConfig={
              type:this.chartType,
              data: {
                labels:this.chartLabels,
                datasets: [
                  {
                    label: this.valueLabel1,
                    data: this.chartData1,
                  },
                ],
              },
              options:{
                legend: {
                  display: false
                },
                title:{},
                fill:'false',
                scales: {
                  yAxes: [{
                    ticks: {
                      beginAtZero: true
                  }
                  }]
                }
              }
            };
          }
          /*else if(this.withThreeData==true){
            //alert(JSON.stringify(this.chartData2));
            var chartData = [];
            this.chartLabels.forEach(function(e,i){
              chartData.push({
                  x:this.chartData2[i],
                  y:this.chartData3[i],
                  r:this.chartData1[i],
              });
            });
            this.chartConfig={
              type:this.chartType,
              data: {
                labels:this.chartLabels,
                datasets: [ 
                  {
                    label: 'test',
                    backgroundColor:'orange',
                    data: [{
                      x:1,
                      y:2,
                      r:2
                    }],
                  }
                ]
              },
              options:{}
            };
          }*/
          
          this.chart = new window.Chart(ctx, JSON.parse(JSON.stringify(this.chartConfig)));
          this.chart.canvas.parentNode.style.height = 'auto';
          this.chart.canvas.parentNode.style.width = '100%';
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