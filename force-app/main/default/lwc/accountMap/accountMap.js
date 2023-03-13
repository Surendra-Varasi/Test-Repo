import { LightningElement, track } from 'lwc';

export default class LightningExampleMapMultipleMarkers extends LightningElement {
    @track
    mapMarkers = [
        {
            value: 'USA1',
            location: {
                Street:"4684 Meridian Ave",
                City: "San Jose",
                PostalCode:"95118",
                State:"CA",
                Country: "USA",
            },
            icon: 'custom:custom26',
            title: "Meridian Ave",
            description: "<b>Opportunity Amount</b> : <i>$800</i>"
        },
        {
            value: 'USA2',
            location:{Street:"1811 Hillsdale Ave",
                City: "San Jose",
                PostalCode:"95124",
                State:"CA",
                Country: "USA",
        },
            icon: 'custom:custom96',
            title: 'Hillsdale Ave',
            description: "<b>Opportunity Amount</b> : <i>$800</i>"
        }
    ];
    
    @track markersTitle = "Côte d'Azur";
    @track newDetailData=[];
    @track detailData=[
        {
           "prodName":'Product 1',
           'sPrice':"200",
           "quantity":"2"
        },
        {
            "prodName":'Product 2',
            'sPrice':'200',
            "quantity":"2"
        },
        {
            "prodName":'Product 3',
            'sPrice':'200',
            "quantity":"2"
        },
        {
           "prodName":'Product 4',
           'sPrice':'200',
           "quantity":"2"
        }];
        @track detailData2=[
            {
               "prodName":'Product 5',
               'sPrice':"200",
               "quantity":"2"
            },
            {
                "prodName":'Product 6',
                'sPrice':'200',
                "quantity":"2"
            },
            {
                "prodName":'Product 7',
                'sPrice':'200',
                "quantity":"2"
            },
            {
               "prodName":'Product 8',
               'sPrice':'200',
               "quantity":"2"
            }];
    @track cols=[
        {
            label: "Product Name", 
            fieldName: "prodName",
            type: "text" 
        },
        {
            label: "Quantity", 
            fieldName: "quantity",
            type: "number" 
        },
        {
            label: "Sales Price", 
            fieldName: "sPrice",
            type: "currency" ,typeAttributes: { currencyCode: 'USD' }
        }
        ];
    @track selectedMarkerValue;
    @track showDetails = "slds-hide";
    handleMarkerSelect(event) {
        this.newDetailData=[];
        console.log("event.detail.selectedMarkerValue  : "+event.detail.selectedMarkerValue + "   detail   "+ JSON.stringify(event.detail));
        this.selectedMarkerValue = event.detail.selectedMarkerValue;
       if(this.selectedMarkerValue=='USA1'){
        this.newDetailData=this.detailData;
       }
       else{
        this.newDetailData=this.detailData2;
       }
        // var newData = {
        //     'prodName':this.selectedMarkerValue,
        //     'date':"2020-09-28"
        // }
        // this.newDetailData.push(newData);
        // this.newDetailData=this.newDetailData.concat(this.detailData);
        this.showDetails="slds-show";
    }
}