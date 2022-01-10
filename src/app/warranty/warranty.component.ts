import { Component, OnInit, ViewChild } from '@angular/core';


import { PoBreadcrumb, PoDynamicFormField, PoModalComponent, PoPageAction } from '@po-ui/ng-components';



@Component({
  selector: 'app-warranty',
  templateUrl: './warranty.component.html',
  styleUrls: ['./warranty.component.css']
})
export class WarrantyComponent implements OnInit {
  @ViewChild(PoModalComponent, { static: true })
  poModal!: PoModalComponent;

  public readonly actions: Array<PoPageAction> = [
    { label: 'Formulário', url: '/FORMULARIO', icon: 'po-icon po-icon-cart' },
  ];
  public readonly breadcrumb: PoBreadcrumb = {
    items: [{ label: 'Home', link: '/' }, { label: 'Garantia' }]
  };

  constructor() { }

  ngOnInit(): void {
  }
  modalOpen() {
    this.poModal.open();
  }

}
