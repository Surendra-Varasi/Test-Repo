import { api, LightningElement, track, wire } from "lwc";
import chartJs from "@salesforce/resourceUrl/ChartJs";
import { loadScript } from "lightning/platformResourceLoader";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';


export default class Chart2 extends LightningElement {

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
    @track newLabel;
    @api withOneData=false;
    @api withTwoData=false;
    @api withThreeData=false;

    
    @track isChartJsInitialized;
    renderedCallback() {
        if (this.isChartJsInitialized) {
         return;
        }
        if(this.valueLabel3 != undefined){
          this.newLabel = this.valueLabel2+'+'+this.valueLabel3;
        }
        else{
          this.newLabel=this.valueLabel2;
        }
        // load static resources.
        Promise.all([loadScript(this, chartJs)])
         .then(() => {
          //alert("Chart Initialized");
          var barOptions_stacked = {
            responsive:true,
            tooltips: {
              mode: 'index',
              intersect: true
            },
            scales: {
                xAxes: [{
                    type:"linear",
                    ticks: {
                        beginAtZero:true,
                        fontFamily: "'Open Sans Bold', sans-serif",
                        fontSize:11
                    },
                    scaleLabel:{
                        display:false
                    },
                    gridLines: {
                    }, 
                    stacked: true
                }],
                yAxes: [{
                    gridLines: {
                        display:false,
                        color: "#fff",
                        zeroLineColor: "#fff",
                        zeroLineWidth: 0
                    },
                    ticks: {
                        fontFamily: "'Open Sans Bold', sans-serif",
                        fontSize:11
                    },
                    stacked: true
                }]
            },  
            pointLabelFontFamily : "Quadon Extra Bold",
            scaleFontFamily : "Quadon Extra Bold",
          };
          this.isChartJsInitialized = true;
          const ctx = this.template.querySelector('canvas.chart').getContext('2d');
            this.chartConfig={
              type:this.chartType,
              data: {
                //labels: this.chartLabels,
                labels: [this.valueLabel1, this.newLabel],
                datasets: this.valueLabel3!=undefined?[
                  {
                    label: this.valueLabel1,
                    backgroundColor:'rgba(115,115,115,0.8)',
                    //data: this.chartData1
                    data:[this.chartData2]
                  },
                  {
                    label: this.valueLabel2,
                    backgroundColor:'rgba(94,109,255,0.8)',
                    //borderColor: 'rgba(193,46,12,1)',
                    //data: this.chartData1
                    data:[,this.chartData1]
                  },
                  {
                    label: this.valueLabel3,
                    backgroundColor:'rgba(251,180,57,0.8)',
                    //borderColor: 'rgba(60,186,159,1)',
                    //data: this.chartData3
                    data:[,this.chartData3]
                  },
                ]:
                [
                  {
                    label: this.valueLabel1,
                    backgroundColor:'rgba(115,115,115,0.8)',
                    //data: this.chartData1
                    data:[this.chartData2]
                  },
                  {
                    label: this.valueLabel2,
                    backgroundColor:'rgba(94,109,255,0.8)',
                    //borderColor: 'rgba(193,46,12,1)',
                    //data: this.chartData1
                    data:[,this.chartData1]
                  },
                ],
              },
              options:barOptions_stacked,
              // {
              //   barValueSpacing: 20,
              //   scales: {
              //       yAxes: [{
              //           ticks: {
              //               min: 0,
              //           }
              //       }]
              //   }
              // }
            };
            if (this.chart) {
              this.chart.update();
              //alert("updated");
            }
            else{
              this.chart = new window.Chart(ctx, JSON.parse(JSON.stringify(this.chartConfig)));
              // Chart.scaleService.updateScaleDefaults('linear', {
              //   ticks: {
              //     callback: function(tick) {
              //       var intValue = parseInt(tick);
              //       var strValue ='';
              //       if(intValue > 0 && intValue < 1000){
              //         strValue = '$ ' +intValue.toString();
              //       }
              //       else if(intValue >=1000 && intValue < 1000000){
              //         intValue= intValue/1000;
              //         strValue = '$ ' +intValue.toString() + 'K';
              //       }else if(intValue >= 1000000){
              //         intValue= intValue/1000000;
              //         strValue = '$ ' +intValue.toString() + 'M';
              //       }
                    
              //       return  strValue;
              //     }
              //   }
              // });
              this.chart.canvas.parentNode.style.height = 'auto';
              this.chart.canvas.parentNode.style.width = '100%';
            }
          
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