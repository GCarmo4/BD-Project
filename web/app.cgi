#!/usr/bin/python3
from wsgiref.handlers import CGIHandler
from flask import Flask
from flask import render_template, request, redirect, url_for
import psycopg2
import psycopg2.extras

## SGBD configs
DB_HOST = "db.tecnico.ulisboa.pt"
DB_USER = "USER"
DB_DATABASE = DB_USER
DB_PASSWORD = "PASSWORD"
DB_CONNECTION_STRING = "host=%s dbname=%s user=%s password=%s" % (
    DB_HOST,
    DB_DATABASE,
    DB_USER,
    DB_PASSWORD,
)

app = Flask(__name__)


@app.route("/")
def index():
    try:
        return render_template("index.html")
    except Exception as e:
        return str(e)


@app.route("/ivm")
def list_ivms():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT * FROM ivm;"
        cursor.execute(query)
        return render_template("ivm.html", cursor=cursor)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()


@app.route("/reposicoes")
def show_reposicoes():
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        num_serie = request.args["num_serie"]
        query = "SELECT cat, SUM(nro) FROM evento_reposicao INNER JOIN produto ON evento_reposicao.ean = produto.ean GROUP BY cat, num_serie HAVING num_serie = %s;"
        data = (num_serie,)
        cursor.execute(query, data)
        return render_template("reposicoes.html", params=request.args, cursor=cursor)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()


@app.route("/retalhistas")
def list_retalhistas():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT * FROM retalhista;"
        cursor.execute(query)
        return render_template("retalhistas.html", cursor=cursor)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()

@app.route('/delete_ret', methods=["POST"])
def delete_ret():
    dbConn=None
    cursor=None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
        tin=request.form["ret_tin"]
        query = 'DELETE FROM retalhista WHERE tin = %s;'
        data=(tin,)
        cursor.execute(query,data)
        return redirect(url_for("list_retalhistas"))
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route('/new_retalhista')
def new_ret():
    try:
        return render_template("new_ret.html")
    except Exception as e:
        return str(e)

@app.route('/create_ret', methods=["POST"])
def create_ret():
    dbConn=None
    cursor=None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
        tin=request.form["tin"]
        nome=request.form["nome"]
        query = 'insert into retalhista values (%s, %s);'
        data=(tin, nome)
        cursor.execute(query,data)
        return redirect(url_for("list_retalhistas"))
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route("/categorias")
def list_cats():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT * FROM categoria;"
        cursor.execute(query)
        return render_template("categorias.html", cursor=cursor)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()

@app.route('/delete_cat', methods=["POST"])
def delete_cat():
    dbConn=None
    cursor=None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
        cat=request.form["cat_name"]
        query = 'DELETE FROM categoria WHERE nome = %s;'
        data=(cat,)
        cursor.execute(query,data)
        return redirect(url_for("list_cats"))
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route('/new_cat_root')
def new_cat_root():
    try:
        return render_template("new_cat_root.html")
    except Exception as e:
        return str(e)

@app.route('/create_cat_root', methods=["POST"])
def create_cat():
    dbConn=None
    cursor=None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
        nome=request.form["nome"]
        query = 'insert into categoria values (%s); insert into categoria_simples values (%s);'
        data=(nome, nome)
        cursor.execute(query,data)
        return redirect(url_for("list_cats"))
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route('/new_cat_in')
def new_cat_in():
    try:
        return render_template("new_cat_in.html", params=request.args)
    except Exception as e:
        return str(e)

@app.route('/create_cat_in', methods=["POST"])
def create_cat_in():
    dbConn=None
    cursor=None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
        nome=request.form["nome"]
        nome_super=request.form["cat_name"]
        query = "SELECT nome FROM super_categoria WHERE nome = %s;"
        data = (nome_super,)
        cursor.execute(query, data)
        rows = cursor.fetchone()
        cursor.close()
        cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
        if (rows):
            query = 'insert into categoria values (%s); insert into categoria_simples values (%s); insert into tem_outra values (%s, %s);'
            data=(nome, nome, nome_super, nome)
            cursor.execute(query,data)
            return redirect(url_for("list_cats"))
        else:
            query = 'insert into categoria values (%s); insert into categoria_simples values (%s); DELETE FROM categoria_simples WHERE nome = %s; insert into super_categoria values (%s); insert into tem_outra values (%s, %s);'
            data=(nome, nome, nome_super, nome_super, nome_super, nome)
            cursor.execute(query,data)
            return redirect(url_for("list_cats"))
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route('/expand_cat')
def expand_cat():
    dbConn=None
    cursor=None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
        cat = request.args["categoria"]
        query = "SELECT categoria FROM tem_outra WHERE super_categoria = %s;"
        data=(cat,)
        cursor.execute(query,data)
        rows = cursor.fetchone()
        cursor.close()
        cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
        if (rows):
            query = "SELECT categoria FROM tem_outra WHERE super_categoria = %s;"
            data=(cat,)
            cursor.execute(query,data)
            return render_template("expand_cat.html", params=request.args, cursor=cursor)
        else:
            return render_template("cat_simples.html", params=request.args, cursor=cursor)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

CGIHandler().run(app)
