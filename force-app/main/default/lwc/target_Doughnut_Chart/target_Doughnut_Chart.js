import { api, LightningElement, track, wire } from "lwc";
import chartJs from "@salesforce/resourceUrl/ChartJs";
import { loadScript } from "lightning/platformResourceLoader";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class Target_Doughnut_Chart extends LightningElement {
    @api loaderVariant = 'base';
    @track chartConfig;
    @api chartLabels;
    @api backgroundColor;
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
                    backgroundColor : this.backgroundColor
                  },
                ],
              },
              options:{
                title:{},
                fill:'false',
                layout: {
                  padding: {
                      left: 0,
                      right: 100,
                      top: 0,
                      bottom: 0
                  }
              }
              }
            };
          }
          this.chart = new window.Chart(ctx, JSON.parse(JSON.stringify(this.chartConfig)));
          this.chart.canvas.parentNode.style.height = '120%';
          this.chart.canvas.parentNode.style.width = '120%';
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