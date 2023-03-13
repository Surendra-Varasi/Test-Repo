import { api, LightningElement, track, wire } from "lwc";
import chartJs from "@salesforce/resourceUrl/ChartJs";
import { loadScript } from "lightning/platformResourceLoader";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getPeopleView from '@salesforce/apex/account_Home_Page_Controller.getPeopleView';
export default class People_View_Chart extends LightningElement {

    @api loaderVariant = 'base';
    @track chartConfig;
    @api chartLabels=[];
    @api chartLabel1;
    @api chartData1=[];
    @api chartData2=[];
    @api chartData3=[];
    @api chartType;
    @api valueLabel1;
    @api valueLabel2;
    @api valueLabel3;
    @api yearValue;
    @track data;
    @track showChart = false;
    @track isChartJsInitialized;

    renderedCallback() {
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
      // var UserDefinedScaleDefaults = Chart.scaleService.getScaleDefaults("linear");
      //         var UserDefinedScale = Chart.scaleService.getScaleConstructor("linear").extend({
      //           buildTicks: function() {
      //             this.min = this.options.ticks.min;
      //             this.max = this.options.ticks.max;
      //             var stepWidth = this.options.ticks.stepWidth;
                  
      //             // Then calulate the ticks
      //             this.ticks = [];
      //             for (var tickValue = this.min; tickValue <= this.max; tickValue += stepWidth) {
      //               alert(tickValue);
      //               // var intValue = parseInt(tickValue);
      //               // var strValue ='';
      //               // if(intValue > 0 && intValue < 1000){
      //               //   strValue = '$ ' +intValue.toString();
      //               // }
      //               // else if(intValue >=1000 && intValue < 1000000){
      //               //   intValue= intValue/1000;
      //               //   strValue = '$ ' +intValue.toString() + 'K';
      //               // }else if(intValue >= 1000000){
      //               //   intValue= intValue/1000000;
      //               //   strValue = '$ ' +intValue.toString() + 'M';
      //               // }
      //               this.ticks.push(tickValue);
      //             }

      //             if (this.options.position == "left" || this.options.position == "right") {
      //               // We are in a vertical orientation. The top value is the highest. So reverse the array
      //               this.ticks.reverse();
      //             }

      //             if (this.options.ticks.reverse) {
      //               this.ticks.reverse();

      //               this.start = this.max;
      //               this.end = this.min;
      //             } else {
      //               this.start = this.min;
      //               this.end = this.max;
      //             }

      //             this.zeroLineIndex = this.ticks.indexOf(0);
      //           }
      //         });
      //         Chart.scaleService.registerScaleType("user-defined", UserDefinedScale, UserDefinedScaleDefaults);
        //alert(this.yearValue);
        // getPeopleView({year:this.yearValue})
        //   .then(result=>{
        //     if (result) {
        //       this.showChart = false;
        //         this.data = result; 
        //         for(var i=0;i<this.data.length;i++){
        //             this.chartLabels.push(this.data[i].userName);
        //             this.chartData1.push(this.data[i].achieved);
        //             this.chartData2.push(this.data[i].pipeline);
        //             this.chartData3.push(this.data[i].target);
        //         }
                //alert('target'+JSON.stringify(this.chartData3));
                //alert('pipeline'+JSON.stringify(this.chartData2));
                //alert('achieved'+JSON.stringify(this.chartData1));
                //alert(JSON.stringify(this.chartData1));
                if (this.isChartJsInitialized) {
                    return;
                   }
                   this.showChart = true;
                   // load static resources.
                   Promise.all([loadScript(this, chartJs)])
                    .then(() => {
                     this.isChartJsInitialized = true;
                     const ctx = this.template.querySelector('canvas.chart').getContext('2d');
                       this.chartConfig={
                         type: 'bar',
                         height: 300,
                      data: {
                      datasets: [{
                        label: 'Achieved',
                        data: this.chartData1,
                        yAxisID: "y-axis-1",
                        backgroundColor:'rgba(94,109,255,0.8)'
                    },{
                      label: 'Pipeline',
                      data: this.chartData2,
                      yAxisID: "y-axis-1",
                      backgroundColor:'rgba(251,180,57,0.8)'
                  },{
                    label:'Target',
                    data:this.chartData3,
                    yAxisID: "y-axis-1",
                    backgroundColor:'rgba(0, 0, 0,1)',
                    borderColor:'rgba(255,255,255,0)',
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
                     yAxes: [{
                      //scaleLabel:
                      //function(label){return  '$' + label.value.toString();},
                      //scaleOverride: true,
                       type:"linear",
                       display:true,
                       stacked: true,
                       position: "left",
                       id:"y-axis-1",
                       ticks: {
                          beginAtZero: true,
                          display:true,
                     }
                     }],
                     xAxes: [{
                         stacked:true,
                         ticks: {
                           beginAtZero: true,
                         }
                       }
                   ]
                 }
                }
                       };     

                     this.chart = new window.Chart(ctx, JSON.parse(JSON.stringify(this.chartConfig)));
                     Chart.scaleService.updateScaleDefaults('linear', {
                      ticks: {
                        callback: function(tick) {
                          var intValue = parseInt(tick);
                          var strValue ='';
                          if(intValue >= 0 && intValue<6){
                            strValue = intValue.toString();
                          }
                          else if(intValue > 6 && intValue < 1000){
                            strValue = '$ ' +intValue.toString();
                          }
                          else if(intValue >=1000 && intValue < 1000000){
                            intValue= intValue/1000;
                            strValue = '$ ' +intValue.toString() + 'K';
                          }else if(intValue >= 1000000){
                            intValue= intValue/1000000;
                            strValue = '$ ' +intValue.toString() + 'M';
                          }
                          
                          return  strValue;
                        }
                      }
                    });
                    
                    
                     this.chart.canvas.parentNode.style.height = '70%';
                     this.chart.canvas.parentNode.style.width = '70%';
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