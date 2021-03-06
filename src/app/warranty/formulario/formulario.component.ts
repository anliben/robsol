import { Component, OnInit, ViewChild } from '@angular/core';
import { HttpClient } from '@angular/common/http';

import {
  PoBreadcrumb,
  PoDynamicViewField,
  PoModalAction,
  PoModalComponent,
  PoNotificationService,
  PoSelectOption,
  PoStepComponent,
  PoStepperComponent,
  PoTableAction,
  PoTableColumn,
  PoUploadFileRestrictions,
} from '@po-ui/ng-components';
import { environment } from 'src/environments/environment';
import { NgForm } from '@angular/forms';

@Component({
  selector: 'app-formulario',
  templateUrl: './formulario.component.html',
  styleUrls: ['./formulario.component.css'],
})
export class FormularioComponent implements OnInit {
  @ViewChild(PoStepperComponent)
  stepper!: PoStepperComponent;
  @ViewChild('userDetailModal') userDetailModal: PoModalComponent | undefined;
  @ViewChild('produtoForm', { static: true }) produtoForm!: NgForm;
  @ViewChild('produtoInputForm', { static: true })
  produtoInputForm!: NgForm;
  @ViewChild('userDetailProduto') userDetailProduto:
    | PoModalComponent
    | undefined;

  @ViewChild('sucessData', { static: true })
  sucessData!: PoModalComponent;

  buttonChooseProduct: boolean = false;

  codigo: boolean = true;
  chooseProduct: boolean = false;
  exchange: boolean = false;
  update: boolean = false;
  notes: boolean = false;
  finish: boolean = false;
  uploaded: boolean = false;
  valuesEspelhoNota: Array<any> = [];
  valuesConfirm: Array<any> = [];

  urls = '';

  event!: string;
  input: string | undefined;
  descricao: string | undefined;
  produto: string | undefined;
  detailedUser!: {
    codigo: any;
    descricao: any;
    ean: any;
    grupo: any;
    imagem: any;
    ncm: any;
    saldo: any;
    tipo: any;
    um: any;
  };
  detailedProduto: Array<any> = [];
  items: Array<any> = [];
  upload: Array<any> = [];


  readonly detailFields: Array<PoDynamicViewField> = [
    { property: 'item' },
    { property: 'cod_produto' },
    { property: 'preco' },
    { property: 'nota' },
    { property: 'quantidade' },
    { property: 'emissao' },
    { property: 'bairro_empresa', divider: 'Dados da empresa' },
    { property: 'nome_empresa', gridColumns: 6 },
    { property: 'cnpj' },
    { property: 'endereco_empresa', gridColumns: 8 },
    { property: 'cidade_empresa' },
    { property: 'estado_empresa' },
    { property: 'inscr_estadual' },
    { property: 'base_icm', divider: 'Detalhes ' },
    { property: 'chave_nfe', gridColumns: 12 },
    { property: 'desc_cfop', gridColumns: 12 },
    { property: 'filial_faturamento' },
    { property: 'serie' },
    { property: 'valor_icm' },
    { property: 'valor_ipi' },
  ];

  fieldsConfirm: Array<PoDynamicViewField> = [
    { property: 'trocar', divider: 'Op????es de Troca' },
    { property: 'descricao' },
  ];

  restrictions: PoUploadFileRestrictions = {
    allowedExtensions: ['.jpg', '.png', '.jpeg', '.webp'],
  };

  public readonly breadcrumb: PoBreadcrumb = {
    items: [
      { label: 'Home', link: '/' },
      { label: 'Garantia', link: '/WARRANTY' },
      { label: 'Formulario' },
    ],
  };

  readonly all: Array<PoSelectOption> = [
    { label: 'Trocar Tudo', value: 'all' },
    { label: 'Trocar Pe??as', value: 'single' },
  ];

  tableActions: Array<PoTableAction> = [
    {
      label: 'Details',
      action: this.onClickProdutoDetail.bind(this),
      icon: 'po-icon po-icon-finance',
    },
  ];
  columns: Array<PoTableColumn> = [
    { property: 'nota' },
    { property: 'item' },
    { property: 'cod_produto' },
    { property: 'quantidade' },
    { property: 'preco' },
    { property: 'emissao' },
  ];

  constructor(public http: HttpClient) {}

  ngOnInit(): void {}

  confirm: PoModalAction = {
    action: () => {
      this.sucessData.close();
    },
    label: 'Return',
  };

  valited(item: string) {
    if (item == 'codigo' && this.input) {
      this.onClickUserDetail();
      this.codigo = false;
      this.chooseProduct = true;
    }

    if (item == 'chooseProduct') {
      this.codigo = false;
      this.chooseProduct = false;
      this.exchange = true;
    }
    if (item == 'buttonExchange' && this.descricao) {
      this.valuesConfirm.push({ property: 'descricao', value: this.descricao });
      this.valuesConfirm.push({ property: 'produto', value: this.produto });
      this.valuesConfirm.push({ property: 'troca', value: this.input });
      this.codigo = false;
      this.chooseProduct = false;
      this.exchange = false;
      this.uploaded = true;
    }
    if (item == 'uploaded') {
      this.uploaded = false;
      this.notes = true;
    }
    if (item == 'notes') {
      this.notes = false;
      this.finish = true;
    }
  }
  chooseSelect(item: string) {
    this.buttonChooseProduct = true;
  }
  chooseDeselect(item: string) {
    this.buttonChooseProduct = false;
  }

  changeEventRepo(event: string) {
    console.log(event);
    this.event = event;
  }
  changeEvent(event: string) {
    console.log('event', event);
    this.event = event;
  }

  onClickUserDetail() {
    let url =
      environment.api +
      `FieldService/?codigo=${
        this.input
      }&cod_cliente=05290313&loja_cliente=${localStorage.getItem(
        'loja_cliente'
      )}`;
    this.http.get(url).subscribe((response: any) => {
      response['items'].forEach((element: any) => {
        this.valuesEspelhoNota = element;

        this.items.push({
          nota: element['nota'],
          item: element['item'],
          cod_produto: element['cod_produto'],
          quantidade: element['quantidade'],
          preco: element['preco'],
          emissao: element['emissao'],
        });
      });
    });
    //this.userDetailModal!.open();
  }

  private onClickProdutoDetail(user: any) {
    let url =
      environment.api +
      `FieldService/?codigo=${
        user['cod_produto']
      }&cod_cliente=05290313&loja_cliente=${localStorage.getItem(
        'loja_cliente'
      )}`;
    this.http.get(url).subscribe((res: any) => {
      console.log(res);
      this.detailedProduto = res['items'][0];
    });
    this.userDetailProduto!.open();
  }
}
