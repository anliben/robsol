import { Component, OnInit, ViewChild } from '@angular/core';
import { HttpClient } from '@angular/common/http';

import { PoBreadcrumb, PoNotificationService, PoPageAction, PoSelectOption, PoStepperComponent, PoTableAction, PoTableColumn, PoTableColumnSort } from '@po-ui/ng-components';

@Component({
  selector: 'app-formulario',
  templateUrl: './formulario.component.html',
  styleUrls: ['./formulario.component.css']
})
export class FormularioComponent implements OnInit {
  @ViewChild(PoStepperComponent)
  stepper!: PoStepperComponent;

  event!: string;
  url: string = 'http://200.98.81.201:40160/rest/Products/?VENDEDOR=';

  public readonly breadcrumb: PoBreadcrumb = {
    items: [{ label: 'Home', link: '/' }, { label: 'Garantia', link: '/WARRANTY' }, { label: 'Formulario' }]
  };

  readonly all: Array<PoSelectOption> = [
    { label: 'Trocar Tudo', value: 'all' },
    { label: 'Trocar Peças', value: 'single' },
  ];

  tableActions: Array<PoTableAction> = [
    {
      label: 'Details',
      action: this.goNext.bind(this),
      icon: 'po-icon po-icon-finance'
    }
  ]



  constructor(public http: HttpClient, private poNotification: PoNotificationService) {}

  ngOnInit(): void {
  }

  goNext(produto: any){
    console.log(produto, this)
    this.stepper.next();
  }
  changeEventRepo(event: string) {
    this.event = event;
    console.log(event)
  }
  changeEvent(event: string) {
    this.event = event;
    console.log(this.event)
    this.stepper.next();
  }

  nextStep(){
    if(this.event == 'p-success'){
      this.poNotification.success('Upload com sucesso!')
      this.stepper.next()
    }
  }


}
