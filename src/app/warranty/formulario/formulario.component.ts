import { Component, OnInit, ViewChild } from '@angular/core';
import { HttpClient } from '@angular/common/http';

import { PoBreadcrumb, PoDynamicViewField, PoModalAction,
  PoModalComponent, PoNotificationService, PoSelectOption, PoStepperComponent, PoTableAction,
  PoTableColumn, PoUploadFileRestrictions } from '@po-ui/ng-components';
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
  detailedProduto: Array<any> = []
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
    { property: 'nota'},
    { property: 'item'},
    { property: 'cod_produto'},
    { property: 'quantidade'},
    { property: 'preco'},
    { property: 'emissao' },
  ];

  readonly detailFields: Array<PoDynamicViewField> = [
    { property: 'item'},
    { property: 'cod_produto'},
    { property: 'preco'},
    { property: 'nota'},
    { property: 'quantidade'},
    { property: 'emissao'},
    { property: 'bairro_empresa', divider: 'Dados da empresa'},
    { property: 'nome_empresa', gridColumns: 6},
    { property: 'cnpj'},
    { property: 'endereco_empresa', gridColumns: 8},
  { property: 'cidade_empresa'},
  { property: 'estado_empresa'},
  { property: 'inscr_estadual'},
  { property: 'base_icm', divider: 'Detalhes '},
  { property: 'chave_nfe'},
  { property: 'desc_cfop', gridColumns: 12},
  { property: 'filial_faturamento'},
  { property: 'serie'},
  { property: 'valor_icm'},
  { property: 'valor_ipi'},
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
    let url = environment.api + `FieldService/?codigo=${this.input}&cod_cliente=05290313&loja_cliente=${localStorage.getItem('loja_cliente')}`
    this.http.get(url).subscribe((response: any) =>{
      response['items'].forEach((element: any) =>{
        this.items.push({
          nota: element['nota'],
          item: element['item'],
          cod_produto: element['cod_produto'],
          quantidade: element['quantidade'],
          preco: element['preco'],
          emissao: element['emissao']
        })
      })
    })
    this.stepper.next();
    //this.userDetailModal!.open();
  }

  private onClickProdutoDetail(user: any) {
    console.log(user['cod_produto'])
    let url = environment.api + `FieldService/?codigo=${user['cod_produto']}&cod_cliente=05290313&loja_cliente=${localStorage.getItem('loja_cliente')}`
    this.http.get(url).subscribe((res: any)=>{
      console.log(res['items'][0])
      this.detailedProduto = res['items'][0]
    })
    this.userDetailProduto!.open();
  }
}
