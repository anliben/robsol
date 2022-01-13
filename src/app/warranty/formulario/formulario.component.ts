import { Component, OnInit, ViewChild } from '@angular/core';
import { HttpClient } from '@angular/common/http';

import { PoBreadcrumb, PoDynamicViewField, PoModalAction, PoModalComponent, PoNotificationService, PoSelectOption, PoStepperComponent, PoTableAction, PoTableColumn, PoUploadFileRestrictions } from '@po-ui/ng-components';
import { environment } from 'src/environments/environment';

@Component({
  selector: 'app-formulario',
  templateUrl: './formulario.component.html',
  styleUrls: ['./formulario.component.css']
})
export class FormularioComponent implements OnInit {
  @ViewChild(PoStepperComponent)
  stepper!: PoStepperComponent;
  @ViewChild('userDetailModal') userDetailModal: PoModalComponent | undefined;
  @ViewChild('userDetailProduto') userDetailProduto: PoModalComponent | undefined;
  @ViewChild('sucessData', { static: true })
  sucessData!: PoModalComponent;

  confirm: PoModalAction = {
    action: () => {
      this.sucessData.close();
    },
    label: 'Return'
  };

  event!: string;
  input: string | undefined;
  produto: string | undefined;
  detailedUser!: { codigo: any; descricao: any; ean: any; grupo: any; imagem: any; ncm: any; saldo: any; tipo: any; um: any; };
  detailedProduto!: { codigo: any; descricao: any; ean: any; grupo: any; imagem: any; ncm: any; saldo: any; tipo: any; um: any; };
  items: Array<any> =[]
  upload: Array<any> =[]

  restrictions: PoUploadFileRestrictions = {
    allowedExtensions: ['.jpg', '.png', '.jpeg', '.webp'],

  };


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
      action: this.onClickProdutoDetail.bind(this),
      icon: 'po-icon po-icon-finance'
    }
  ]
  columns: Array<PoTableColumn> = [
    { property: 'codigo'},
        { property: 'descricao'},
        { property: 'cor'},
        { property: 'marca'},
        { property: 'linha'},
        { property: 'material' },
        { property: 'genero'},
  ];

  readonly detailFields: Array<PoDynamicViewField> = [
    { property: 'codigo', gridColumns: 4 },
    { property: 'um', gridColumns: 4, label: 'UM' },
    { property: 'tipo', gridColumns: 4 },
    { property: 'descricao', gridColumns: 12, divider: 'Descrição' },
    { property: 'grupo', gridColumns: 12, divider: 'Grupo' },
    { property: 'formato', gridColumns: 4, divider: 'Formato' },
    { property: 'cor', gridColumns: 4 },
    { property: 'saldo', gridColumns: 4 },
    { property: 'ncm', gridColumns: 4 },
    { property: 'ean', gridColumns: 4 },
  ];


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
  confirmSubmit() {
    this.sucessData.open();
    this.stepper.first();
  }

  onClickUserDetail() {
    console.log(this.input)
    let url = environment.api + `Products/?codigo=${this.input}`
    this.http.get(url).subscribe((response: any) =>{
      this.items.push(response)
    })
    this.stepper.next();
    //this.userDetailModal!.open();
  }

  private onClickProdutoDetail(user: any) {
    let produtosapi = environment.api + `Products/&codigo=${user['codigo']}`
    this.http.get(produtosapi).subscribe((res: any)=>{
      this.detailedProduto = res
    })
    this.userDetailProduto!.open();
  }



}
