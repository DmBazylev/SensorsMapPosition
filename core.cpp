#include "core.h"

Core::Core(QObject *parent) : QObject(parent)
{

}

void Core::slotQuit()
{
    qApp->quit();//Глобальный указатель, ссылающийся на уникальный объект приложения
}
